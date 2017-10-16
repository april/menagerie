require 'csv'

namespace :illustrations do

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
    Printing.connection.execute(%{
      COPY (
        SELECT
          pi.*,
          c.name,
          c.name_2,
          c.layout,
          a.name,
          s.code
        FROM (
          SELECT
            p.id AS printing_id,
            p.artist_id,
            p.oracle_id,
            p.set_id,
            p.frame,
            jsonb(p.image_data->>'normal')->>'id' AS image_normal,
            jsonb(p.image_data->>'large')->>'id' AS image_large,
            jsonb(p.image_2_data->>'normal')->>'id' AS image_2_normal,
            jsonb(p.image_2_data->>'large')->>'id' AS image_2_large
          FROM #{ENV.fetch('SCRYFALL_DATABASE_SERVER')}.printings p
          FULL OUTER JOIN printing_illustrations j ON p.id = j.printing_id
          WHERE p.artist_id IS NOT NULL AND j.illustration_id IS NULL
        ) as pi
        JOIN #{ENV.fetch('SCRYFALL_DATABASE_SERVER')}.oracle_cards c ON c.id = pi.oracle_id
        JOIN #{ENV.fetch('SCRYFALL_DATABASE_SERVER')}.artists a ON a.id = pi.artist_id
        JOIN #{ENV.fetch('SCRYFALL_DATABASE_SERVER')}.magic_sets s ON s.id = pi.set_id
        ORDER BY s.released_at ASC
      ) TO '#{export_csv}' (format CSV);
    }.squish)

    puts "Data export successful, proceeding with import..."

    ids = {}
    oracle_ids = {}
    csv = CSV.read(export_csv)
    csv.each do |row|
      printing_id,
      artist_id,
      oracle_id,
      set_id,
      frame,
      image_1_normal,
      image_1_large,
      image_2_normal,
      image_2_large,
      name_1,
      name_2,
      layout,
      artist,
      set_code = *row

      [name_1, name_2].compact.each_with_index do |name, index|
        face = index + 1
        key = [oracle_id, artist_id, face].join("-")

        if !oracle_ids.key?(oracle_id)
          oracle_name = [name_1, name_2].compact.join(" // ")
          oracle_ids[oracle_id] = true
          puts %{Creating oracle_card "#{oracle_name}"}
          OracleCard.find_or_create_by({
            id: oracle_id,
            name: oracle_name
          })
        end

        if ids.key?(key)
          illustration_id = ids[key]
        elsif illustration = Illustration.where(oracle_id: oracle_id, artist_id: artist_id, face: face).first
          illustration_id = ids[key] = illustration.id
        else
          puts %{Creating illustration "#{name.strip}" by #{artist.strip}}
          illustration_id = ids[key] = Illustration.create({
            printing_id: printing_id,
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