# frozen_string_literal: true

class IllustrationTag < Tag
  has_many :taggables, through: :content_tags, source_type: Illustration.name
end