# frozen_string_literal: true

class TagProposal

  attr_reader :original_name
  attr_reader :formatted_name

  def initialize(name, current_tag=nil, existing_tag=nil)
    @original_name = name.strip.squish

    # Skip duplicate tags
    if current_tag.present?
      @formatted_name = current_tag
      @duplicate_tag = true
      return self
    end

    # Use an existing tag name, if available
    if existing_tag.present?
      @formatted_name = existing_tag
      @existing_tag = true
      return self
    end

    # Lowercase
    lowercased_term = @original_name.downcase
    @lowercased = lowercased_term != @original_name

    # Check full phrase against blacklist
    @blacklisted = BlacklistTerm.blacklist_phrase?(lowercased_term)

    # Check each word against blacklist and spelling
    lowercased_term.split(" ").each do |word|
      @blacklisted ||= BlacklistTerm.blacklist_word?(word)
      @misspelled ||= false
      #@misspelled ||= spelling.correct?(word)
    end

    @nounless = false
    @multiple_nouns = false

    #   @tagger ||= EngTagger.new
    #   nouns = @tagger.get_nouns(@tagger.add_tags(tag)).keys

    #   if nouns.length < 1
    #     self.note = "no nouns present"
    #     return nil
    #   elsif nouns.length > 1
    #     self.note = "multiple nouns present"
    #     return nil
    #   end

    # Singularize
    singularized_term = lowercased_term.singularize
    @singularized = singularized_term != lowercased_term

    # Assign formatted name for display
    @formatted_name = singularized_term
  end

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

  def note
    return "already tagged" if @duplicate_tag
    return "existing tag" if @existing_tag
    return "inappropriate" if @blacklisted
    notes = []
    notes << "lowercase" if @lowercased
    notes << "singular" if @singularized
    return notes.any? ? notes.join(", ") : "okay"
  end

  def duplicate?
    @duplicate_tag
  end

  # Tag is not allowed if it's a duplicate, or blacklisted
  def allowed?
    !@duplicate_tag && !@blacklisted
  end

  def suggest_cancel?
    !allowed? || @nounless || @multiple_nouns
  end

  def suggest_formatted_name?
    !suggest_cancel?
  end

end