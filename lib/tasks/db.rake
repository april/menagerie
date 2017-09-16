require 'CSV'

namespace :db do

  desc "TODO"
  task import: :environment do
    csv = CSV.read(Rails.root.join("db/import.csv"))

    data = csv.map do |row|
      row[0].split("//").each_with_index.map do |name, index|
        artist = row[1]
        {
          name: name.strip,
          artist: artist,
          slug: [name.strip.split(" ")[0..7], artist.strip.split(" ")[1..-1]].flatten.join("-").downcase,
          image_normal_uri: "https://img.scryfall.com/#{row[2]}"
        }
      end
    end

    data.flatten.each_slice(200) do |chunk|
      Illustration.create(chunk)
      puts chunk[0][:name]
      sleep 0
    end
  end

end
