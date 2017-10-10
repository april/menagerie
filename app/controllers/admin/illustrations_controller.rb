# frozen_string_literal: true

class Admin::IllustrationsController < AdminController

  PER_PAGE = 200

  ALL_DUPLICATES_SQL = %{
    SELECT * FROM (
      SELECT
        p.id,
        p.oracle_id,
        p.artist_id,
        p.image_data,
        coalesce(p.illustration_id, j.illustration_id) as illustration_id
      FROM printings p
      FULL OUTER JOIN printings_illustrations j ON p.id = j.printing_id
      WHERE coalesce(p.illustration_id, j.illustration_id) IS NOT NULL
    ) as pi
    WHERE illustration_id IN (
      SELECT illustration_id
      FROM printings_illustrations
      GROUP BY illustration_id
      HAVING COUNT(*) > 1
    )
    ORDER BY (oracle_id, artist_id)
  }.squish.freeze

  # ALL_DUPLICATES_SQL = %{
  #   SELECT id, oracle_id, artist_id, illustration_id, image_data,
  #     count(*) OVER() as total
  #   FROM printings
  #   WHERE illustration_id IN (
  #     SELECT illustration_id
  #     FROM printings
  #     GROUP BY illustration_id
  #     HAVING COUNT(*) > 1
  #   )
  # }.squish.freeze

  # NAMED_DUPLICATES_SQL = %{
  #   #{ALL_DUPLICATES_SQL}
  #   AND id IN (
  #     SELECT printing_id
  #     FROM magic_cards
  #     WHERE name = ?
  #   )
  # }.squish.freeze

  def index
    parameters = [ALL_DUPLICATES_SQL]

    # if params[:name].present?
    #   select_sql = NAMED_DUPLICATES_SQL
    #   parameters << params[:name]
    # end

    # select_sql = %{
    #   #{select_sql}
    #   ORDER BY (oracle_id, artist_id)
    #   OFFSET ? LIMIT ?
    # }.squish

    # @page = params.fetch(:page, 1).to_i
    # parameters << (@page-1) * PER_PAGE
    # parameters << PER_PAGE

    @printings = Printing.paginate_by_sql(parameters, page:[params[:page].to_i, 1].max, per_page:200)
    @last_page = 0
    #@last_page = @printings.present? ? (@printings.first[:total].to_f / PER_PAGE).ceil : 0
  end

  ILLUSTRATION_PRINTINGS_SQL = %{
    SELECT
      p.id,
      p.image_data
    FROM printings p
    FULL OUTER JOIN printings_illustrations j ON p.id = j.printing_id
    WHERE coalesce(p.illustration_id, j.illustration_id) = ?
  }

  def edit
    @illustration = Illustration.find(params[:id])
    @printings = Printing.find_by_sql([ILLUSTRATION_PRINTINGS_SQL, @illustration.id])
  end

  def update
    @illustration = Illustration.find(params[:id])

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
    rels = PrintingIllustration.where(printing_id: printing_ids_to_update).all

    # Update all printings to match new variation criteria
    printings_by_variation.each_pair do |variation_code, printing_ids|
      varient_illustration = Illustration.find(variation_code) if variation_code.length == 36

      Postgres.transaction do
        varient_illustration ||= @illustration.create_printing_variant!(printing_ids.first)

        printing_ids.each do |id|
          if rel = rels.detect {|rel| rel.printing_id == id }
            rel.update_attributes(illustration_id: varient_illustration.id)
          end
        end
      end
    end

    return redirect_to admin_illustrations_path({ name: params[:name] }.compact)
  end

end