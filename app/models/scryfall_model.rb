class ScryfallModel < ActiveRecord::Base
  self.abstract_class = true
  establish_connection SCRYFALL_DB
end