# frozen_string_literal: true

class TagProposal

  attr_reader :original_name
  attr_reader :formatted_name

  def initialize(name, current_tag=nil, existing_tag=nil)
    @original_name = name.strip.squish
    @formatted_name = @original_name
    @omit = false
    @duplicate = false
    @suggest_cancel = false
    @notes = []

    # return self unless check_for_duplicates!(current_tags)
    # return self unless check_for_existing!(existing_tag)

    [
      :check_blacklist!,
      :check_dictionary!,
      :format_lowercase!,
      :format_singular!,
    ].each { |method| return self unless self.send(method) }
  end

  # Form field displays

  def original_name_key
    @original_name_key ||= SecurityToken.generate
  end

  def formatted_name_key
    @formatted_name_key ||= SecurityToken.generate
  end

  def formatted_name_display
    allowed? ? @formatted_name : "n/a"
  end

  def cancel_key
    @cancel_key ||= SecurityToken.generate
  end

  # Other accessors

  def note
    return @notes.any? ? @notes.join(", ") : "okay"
  end

  def duplicate?
    @duplicate
  end

  def allowed?
    !@omit
  end

  def suggest_cancel?
    @suggest_cancel || !allowed? || duplicate?
  end

  def suggest_formatted_name?
    !suggest_cancel?
  end

private

  def check_for_duplicates!(tags)
    @formatted_name = current_tag
    @duplicate = true
    @omit = true
    @notes << "duplicate tag"
    return true
  end

  def check_for_existing!(tags)
    @formatted_name = existing_tag
    @existing_tag = true
    return true
  end

  def check_blacklist!
    blacklisted = WordbankTerm.blacklist_phrase?(@formatted_name.downcase)

    # Check each word against blacklist
    @formatted_name.downcase.split(" ").each do |word|
      blacklisted ||= WordbankTerm.blacklist_word?(word)
    end

    if blacklisted
      @omit = true
      @suggest_cancel = true
      @notes << "inappropriate"
      return false
    end
    return true
  end

  def check_dictionary!
    unknown_words = false

    @formatted_name.downcase.split(" ").each do |word|
      unknown_words ||= !WordbankTerm.dictionary_word?(word)
    end

    if unknown_words
      @suggest_cancel = true
      @notes << "check spelling"
    end
    return true
  end

  def check_nouns!
    nouns = WordbankTerm.get_nouns(@formatted_name.downcase)

    if nouns.length < 1
      @suggest_cancel = true
      @notes << "no nouns"
    elsif nouns.length > 1
      @suggest_cancel = true
      @notes << "multiple nouns"
    end
    return true
  end

  def format_lowercase!
    previous_name = @formatted_name
    @formatted_name = @formatted_name.downcase
    @notes << "lowercased" if @formatted_name != previous_name
    return true
  end

  def format_singular!
    previous_name = @formatted_name
    @formatted_name = @formatted_name.singularize
    @notes << "singularized" if @formatted_name != previous_name
    return true
  end

end