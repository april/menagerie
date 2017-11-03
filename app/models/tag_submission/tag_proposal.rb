# frozen_string_literal: true

class TagSubmission::TagProposal

  attr_reader :original_name
  attr_reader :formatted_name
  attr_reader :type

  VALID_TYPES = [
    ContentTag::Type::ILLUSTRATION,
    ContentTag::Type::ORACLE_CARD,
  ].freeze

  def initialize(opts, current_tag=nil, existing_tag=nil)
    @original_name = opts.fetch(:name, "").strip.squish
    @type = opts.fetch(:type, VALID_TYPES[0]).strip.squish
    @formatted_name = @original_name
    @omit = false
    @duplicate = false
    @suggest_cancel = false
    @notes = []

    # Invalid types default as illustration tags
    @type = VALID_TYPES[0] unless VALID_TYPES.include?(@type)

    return self if check_duplicate!(current_tag)
    return self if check_existing!(existing_tag)

    [
      :check_length!,
      :check_blacklist!,
      :check_dictionary!,
      :format_lowercase!,
      :format_singular!,
    ].each { |method| return self if self.send(method) }
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

  def oracle_tag?
    type == ContentTag::Type::ORACLE_CARD
  end

  def original_tag_store
    { model: ContentTag.name, name: @original_name, oracle: oracle_tag? }
  end

  def formatted_tag_store
    { model: ContentTag.name, name: @formatted_name, oracle: oracle_tag? }
  end

  def type_short
    oracle_tag?? "card" : "artwork"
  end

  # Other accessors

  def note
    return @notes.any? ? @notes.join(", ") : "okay"
  end

  def duplicate?
    @duplicate
  end

  def existing?
    @existing
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

  def allow_original_name?
    allowed? && !existing?
  end

private

  def check_duplicate!(current_tag)
    if current_tag.present? && current_tag.downcase == @original_name.downcase
      @formatted_name = current_tag
      @duplicate = true
      @omit = true
      @notes << "duplicate tag"
      return true
    end
    return false
  end

  def check_existing!(existing_tag)
    if existing_tag.present? && existing_tag.downcase == @original_name.downcase
      @formatted_name = existing_tag
      @existing = true
      @notes << "joins existing tag"
      return true
    end
    return false
  end

  def check_length!
    if @original_name.length < 2 || @original_name.length > 30
      @omit = true
      @suggest_cancel = true
      @notes << (@original_name.length < 2) ? "too short" : "too long"
      return true
    end
    return false
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
      return true
    end
    return false
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
    return false
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
    return false
  end

  def format_lowercase!
    previous_name = @formatted_name
    @formatted_name = @formatted_name.downcase
    @notes << "lowercased" if @formatted_name != previous_name
    return false
  end

  def format_singular!
    previous_name = @formatted_name
    @formatted_name = @formatted_name.singularize
    @notes << "singularized" if @formatted_name != previous_name
    return false
  end

end