# frozen_string_literal: true

class BlacklistTerm < ActiveRecord::Base

  def self.blacklist
    @blacklist ||= begin
      @blacklist_dict ||= YAML.load_file(Rails.root.join("config/blacklist.yml"))
      Struct.new(:phrases, :words).new(*@blacklist_dict.partition { |t| t.include?(" ") }.map(&:to_set))
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

end