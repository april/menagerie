# frozen_string_literal: true

class Admin::IllustrationsController < AdminController

  PER_PAGE = 200

  ALL_DUPLICATES_SQL = %{
    SELECT id, oracle_id, artist_id, illustration_id, image_data,
      count(*) OVER() as total
    FROM printings
    WHERE illustration_id IN (
      SELECT illustration_id
      FROM printings
      GROUP BY illustration_id
      HAVING COUNT(*) > 1
    )
  }.squish.freeze

  NAMED_DUPLICATES_SQL = %{
    #{ALL_DUPLICATES_SQL}
    AND id IN (
      SELECT printing_id
      FROM magic_cards
      WHERE name = ?
    )
  }.squish.freeze

  def index
    select_sql = ALL_DUPLICATES_SQL
    parameters = []

    if params[:name].present?
      select_sql = NAMED_DUPLICATES_SQL
      parameters << params[:name]
    end

    select_sql = %{
      #{select_sql}
      ORDER BY (oracle_id, artist_id)
      OFFSET ? LIMIT ?
    }.squish

    @page = params.fetch(:page, 1).to_i
    parameters << (@page-1) * PER_PAGE
    parameters << PER_PAGE

    @printings = Printing.with_sql(select_sql, *parameters).all
    @last_page = @printings.present? ? (@printings.first[:total].to_f / PER_PAGE).ceil : 0
  end

  def edit
    @illustration = Illustration.first(id:params[:id]) or return http404
    @magic_cards = @illustration.magic_cards.all
  end

  def split
    illustration = Illustration.first(id: params[:id]) or return http404

    variations_by_printing = params.fetch(:printing_illustrations, {}).fetch(:variants, {})
    printings_by_variation = {}
    printing_ids_to_update = []

    # Invert submitted mapping into unique group codes
    # each holding a collection of printing ids
    variations_by_printing.each_pair do |printing_id, variation_code|
      if variation_code.present?
        printings_by_variation[variation_code] ||= []
        printings_by_variation[variation_code] << printing_id
        printing_ids_to_update << printing_id
      end
    end

    # Fetch all printings to update with a single query
    printings = Printing.where(id: printing_ids_to_update).all

    # Update all printings to match new variation criteria
    printings_by_variation.each_pair do |variation_code, printing_ids|
      varient_illustration = Illustration.first(id: variation_code) if variation_code.length == 36

      Postgres.transaction do
        varient_illustration ||= Illustration.create(oracle_id: illustration.oracle_id, artist_id: illustration.artist_id)

        printing_ids.each do |id|
          if printing = printings.detect {|p| p.id == id }
            printing.set(illustration_id: varient_illustration.id)
            printing.save
          end
        end
      end
    end

    return redirect_to admin_illustrations_path({ name: params[:name] }.compact)
  end

end