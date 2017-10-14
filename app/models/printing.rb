# frozen_string_literal: true

class Printing < ActiveRecord::Base

  self.table_name = "#{ENV.fetch('SCRYFALL_DATABASE_SERVER')}.printings"

  def image_uri(size)
    return %{https://img.scryfall.com/#{image_data.dig(size.to_s, "id")}}
  end

end