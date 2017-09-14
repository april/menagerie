require 'CSV'

namespace :db do
  desc "TODO"
  task import: :environment do
    Illustration.destroy_all
    csv = CSV.read(Rails.root.join("db/import.csv"))
    data = csv.map { |row| {name: row[0], artist: row[1], image_uri: "https://img.scryfall.com/#{row[2]}"} }
    data.each_slice(100) do |chunk|
      Illustration.create(chunk)
      puts chunk[0][:name]
      sleep 0
    end
  end

end
