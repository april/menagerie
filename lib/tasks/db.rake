require 'CSV'

namespace :db do

  desc "TODO"
  task import: :environment do
    csv = CSV.read(Rails.root.join("db/import.csv"))[0..2000]
    slugs = {}

    data = csv.map do |row|
      row[0].split("//").map do |name|
        artist = row[1] || "anonymous"
        slug = [name.strip.gsub(/[':;,!&%\?\$\+\.]/, "").split(" ")[0..7], artist.strip.split(" ")].flatten.join("-").downcase
        if !slugs.key?(slug)
          slugs[slug] = true;
          {
            name: name.strip,
            artist: artist,
            slug: slug,
            image_normal_uri: row[2].present? ? "https://img.scryfall.com/#{row[2]}" : nil,
            image_large_uri: row[3].present? ? "https://img.scryfall.com/#{row[3]}" : nil,
            image_crop_uri: row[4].present? ? "https://img.scryfall.com/#{row[4]}" : nil
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
