# frozen_string_literal: true

module WordbankTerm

  # Dictionary

  def self.dictionary
    @dictionary ||= YAML.load_file(Rails.root.join("db/dictionary.yml")).to_set.freeze
  end

  def self.dictionary_word?(word)
    return dictionary.include?(word)
  end

  # Blacklist

  def self.blacklist
    @blacklist ||= begin
      blacklist = YAML.load_file(Rails.root.join("db/blacklist.yml")).partition { |t| t.include?(" ") }
      blacklist[0].each do |term|
        blacklist[1] << term.split(" ").join("-")
        blacklist[1] << term.split(" ").join("")
      end
      Struct.new(:phrases, :words).new(*blacklist.map(&:to_set).map(&:freeze))
    end
  end

  def self.blacklist_phrase?(phrase)
    blacklist.phrases.each do |p|
      return true if phrase.include?(p)
    end
    return false
  end

  def self.blacklist_word?(word)
    return blacklist.words.include?(word)
  end

  # Nouns

  def self.noun_tagger
    @noun_tagger ||= EngTagger.new
  end

  def self.get_nouns(phrase)
    noun_tagger.get_nouns(noun_tagger.add_tags(phrase)).keys
  end

end