# frozen_string_literal: true

class Admin::IllustrationsController < AdminController

  PER_PAGE = 200

  ALL_DUPLICATES_SQL = %{
    SELECT *, count(*) OVER() as total
    FROM (
      SELECT
        p.id,
        p.oracle_id,
        p.artist_id,
        jsonb(p.image_data->>'small')->>'id' AS image_path,
        j.illustration_id,
        j.face
      FROM #{ ENV.fetch('SCRYFALL_DATABASE_SERVER') }.printings p
      FULL OUTER JOIN printing_illustrations j ON p.id = j.printing_id
      WHERE j.illustration_id IS NOT NULL
    ) as pi
    WHERE illustration_id IN (
      SELECT illustration_id
      FROM printing_illustrations
      GROUP BY illustration_id
      HAVING COUNT(*) > 1
    )
  }.squish.freeze

  NAMED_DUPLICATES_SQL = %{
    #{ALL_DUPLICATES_SQL}
    AND oracle_id IN (
      SELECT id
      FROM #{ ENV.fetch('SCRYFALL_DATABASE_SERVER') }.oracle_cards
      WHERE name = ?
    )
  }.squish.freeze

  def index
    parameters = []

    if params[:name].present?
      parameters << NAMED_DUPLICATES_SQL
      parameters << params[:name]
    else
      parameters << ALL_DUPLICATES_SQL
    end

    parameters[0] = "#{parameters[0]} ORDER BY (oracle_id, artist_id) OFFSET ? LIMIT ?"

    @page = params.fetch(:page, 1).to_i
    parameters << (@page-1) * PER_PAGE
    parameters << PER_PAGE

    @printings = Printing.find_by_sql(parameters)
    @last_page = @printings.present? ? (@printings.first[:total].to_f / PER_PAGE).ceil : 0
  end

  ILLUSTRATION_PRINTINGS_SQL = %{
    SELECT
      p.id,
      p.image_data
    FROM #{ ENV.fetch('SCRYFALL_DATABASE_SERVER') }.printings p
    FULL OUTER JOIN printing_illustrations j ON p.id = j.printing_id
    WHERE j.illustration_id = ?
  }.squish.freeze

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
      variant_illustration = nil
      variant_illustration = Illustration.find(variation_code) if variation_code.length == 36

      PrintingIllustration.transaction do
        variant_illustration ||= @illustration.create_printing_variant!(printing_ids.first)

        printing_ids.each do |id|
          if rel = rels.detect {|r| r.printing_id == id }
            rel.update_attributes(illustration_id: variant_illustration.id)
          end
        end
      end
    end

    return redirect_to admin_edit_illustrations_path(params[:id])
  end

end