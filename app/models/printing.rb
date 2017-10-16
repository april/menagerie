# frozen_string_literal: true

class Printing < ActiveRecord::Base

  self.table_name = "#{ENV.fetch('SCRYFALL_DATABASE_SERVER')}.printings"

  PRINTING_WITH_SET_CODE = %{
    SELECT p.*, s.code AS set_code
    FROM (
      SELECT * FROM #{ENV.fetch('SCRYFALL_DATABASE_SERVER')}.printings
      WHERE id = ? LIMIT 1
    ) AS p
    JOIN #{ENV.fetch('SCRYFALL_DATABASE_SERVER')}.magic_sets s ON s.id = p.set_id
  }.squish.freeze

  def self.find_with_set_code(id)
    find_by_sql([PRINTING_WITH_SET_CODE, id]).first
  end

  def image_uri(size)
    return %{https://img.scryfall.com/#{image_data.dig(size.to_s, "id")}}
  end

end