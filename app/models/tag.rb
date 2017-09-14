class Tag < ActiveRecord::Base

  has_many :illustration_tags
  has_many :illustrations, through: :illustration_tags

  validates_presence_of :name

  def self.normalize(str)
    str.strip.squish.downcase.singularize
  end

  attr_accessor :note

  ALLOWED_ADJECTIVES = [
    "pink",
    "red",
    "orange",
    "yellow",
    "green",
    "blue",
    "purple",
    "gray",
    "black",
    "white"
  ]

  def original_name
    name.strip.squish
  end

  def normalized_name
    tag = name.strip.squish.downcase
    return tag if ALLOWED_ADJECTIVES.include?(tag)

    @tagger ||= EngTagger.new
    nouns = @tagger.get_nouns(@tagger.add_tags(tag)).keys

    if nouns.length < 1
      self.note = "no nouns present"
      return nil
    elsif nouns.length > 1
      self.note = "multiple nouns present"
      return nil
    end

    return nouns.first.singularize
  end

  def cancel?
    normalized_name
    note.present?
  end

end