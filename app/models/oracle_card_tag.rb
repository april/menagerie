# frozen_string_literal: true

class OracleCardTag < Tag
  has_many :taggables, through: :content_tags, source_type: OracleCard.name
end