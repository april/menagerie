require 'csv'

namespace :db do

  desc "Imports CSV illustration into the database"
  task import: :environment do
    csv = CSV.read(Rails.root.join("db/import.csv"))
    csv = csv[0..2000] unless Rails.env.development?
    slugs = {}

    data = csv.map do |row|
      artist_id, oracle_id, name, artist, image_normal, image_large = *row

      name.split("//").map do |name|
        slug_name = name.to_s.strip.gsub(/(?!-)[[:punct:]]/, "")
        slug_artist = artist.to_s.strip.gsub(/(?!-)[[:punct:]]/, "")
        slug = [slug_name.split(" ")[0..7], slug_artist.split(" ")].flatten.join("-").downcase
        if !slugs.key?(slug)
          slugs[slug] = true;
          {
            oracle_card_id: oracle_id,
            artist_id: artist_id,
            name: name.strip,
            artist: artist,
            slug: slug,
            image_normal_uri: image_normal.present? ? "https://img.scryfall.com/#{image_normal}" : nil,
            image_large_uri: image_large.present? ? "https://img.scryfall.com/#{image_large}" : nil
          }.compact
        end
      end
    end

    data.flatten.compact.each_slice(200) do |chunk|
      Illustration.create(chunk)
      puts chunk[0][:name]
      sleep 0
    end
  end

end
