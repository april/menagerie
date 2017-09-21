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
      :check_spelling!,
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
    !allowed? || duplicate?
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
    @omit ||= BlacklistTerm.blacklist_phrase?(@formatted_name.downcase)

    # Check each word against blacklist
    @formatted_name.downcase.split(" ").each do |word|
      @omit ||= BlacklistTerm.blacklist_word?(word)
    end

    @notes << "inappropriate"
    return !@omit
  end

  def check_spelling!
    @formatted_name.downcase.split(" ").each do |word|
      #@misspelled ||= spelling.correct?(word)
    end
    @notes << "check spelling"
    return true
  end

  def check_nouns!
    #   @tagger ||= EngTagger.new
    #   nouns = @tagger.get_nouns(@tagger.add_tags(tag)).keys

    #   if nouns.length < 1
    #     self.note = "no nouns present"
    #     return nil
    #   elsif nouns.length > 1
    #     self.note = "multiple nouns present"
    #     return nil
    #   end
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