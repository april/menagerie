require 'csv'

namespace :illustrations do

  # desc "Export data for Illustrations"
  # task export: :environment do
  #   ScryfallModel.connection.execute(%{
  #     COPY (
  #       SELECT artists.id, Cards.*
  #       FROM (
  #         SELECT DISTINCT ON (name, artist)
  #           oracle_id,
  #           name,
  #           artist,
  #           jsonb(image_data->>'normal')->>'id',
  #           jsonb(image_data->>'large')->>'id'
  #         FROM magic_cards
  #         WHERE artist IS NOT NULL
  #       ) as Cards
  #       JOIN artists ON artists.name = Cards.artist
  #     ) TO '#{Rails.root.join('db/import.csv')}' (format CSV);
  #   })
  # end

  desc "Import data for illustrations"
  task import: :environment do
    export_csv = Rails.root.join('tmp/illustrations.csv')
    puts "Exporting data to #{export_csv}"

    # Export raw illustration data...
    # This collects data from all printings that:
    # a) have an artist
    # b) have not yet been assigned an illustration_id
    # (illustration ids may be permanently assigned to the printing,
    # or exist within the temporary illustrations join table that
    # stages associations until they are confirmed.)
    ScryfallModel.connection.execute(%{
      COPY (
        SELECT
          pi.printing_id,
          pi.artist_id,
          c.oracle_id,
          c.distinct_names[1] AS name,
          c.distinct_names[2] AS name_2,
          c.artist,
          c.layout,
          c.frame,
          c.set_code,
          jsonb(c.image_data->>'normal')->>'id' AS image_normal,
          jsonb(c.image_data->>'large')->>'id' AS image_large,
          jsonb(c.image_2_data->>'normal')->>'id' AS image_2_normal,
          jsonb(c.image_2_data->>'large')->>'id' AS image_2_large
        FROM (
          SELECT
            p.id AS printing_id,
            p.artist_id,
            coalesce(p.illustration_id, j.illustration_id) as illustration_id
          FROM printings p
          FULL OUTER JOIN printings_illustrations j ON p.id = j.printing_id
          WHERE p.artist_id IS NOT NULL
          AND coalesce(p.illustration_id, j.illustration_id) IS NULL
        ) as pi
        JOIN magic_cards c ON c.printing_id = pi.printing_id
        ORDER BY c.spoiled_at
      ) TO '#{export_csv}' (format CSV);
    })

    puts "Data export successful, proceeding with import..."

    ids = {}
    csv = CSV.read(export_csv)
    csv = csv[0..2000] unless Rails.env.development?
    csv.each do |row|
      printing_id,
      artist_id,
      oracle_id,
      name_1,
      name_2,
      artist,
      layout,
      frame,
      set_code,
      image_1_normal,
      image_1_large,
      image_2_normal,
      image_2_large = *row

      [name_1, name_2].compact.each_with_index do |name, index|
        face = index + 1
        key = [oracle_id, artist_id, face].join("-")

        if ids.key?(key)
          illustration_id = ids[key]
        elsif illustration = Illustration.where(oracle_id: oracle_id, artist_id: artist_id, face: face).first
          illustration_id = ids[key] = illustration.id
        else
          puts %{Creating illustration "#{name.strip}" by #{artist.strip}}
          illustration_id = ids[key] = Illustration.create({
            oracle_id: oracle_id,
            artist_id: artist_id,
            artist: artist.strip,
            name: name.strip,
            face: face,
            layout: layout,
            frame: frame,
            set_code: set_code,
            image_normal: face > 1 && image_2_normal.present?? image_2_normal : image_1_normal,
            image_large: face > 1 && image_2_large.present?? image_2_large : image_1_large
          }.compact).id
        end

        puts %{Joining "#{name.strip}" to #{printing_id}}
        PrintingIllustration.create(
          printing_id: printing_id,
          illustration_id: illustration_id,
          face: face
        )
      end

      sleep 0
    end

    puts "done"
  end

end