# frozen_string_literal: true

class MagicCard < ActiveRecord::Base
  self.table_name = "<%= ENV.fetch('SCRYFALL_DATABASE_SERVER') %>.magic_cards"
end