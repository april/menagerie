class TagProposal

  attr_reader :original_name
  attr_reader :formatted_name

  def initialize(name, current_tags=[])
    @original_name = name.strip.squish
    @existing_tag = current_tags.map(&:downcase).include?(@original_name.downcase)

    @notes = []

    # Lowercase
    lowercased = @original_name.downcase
    @lowercased = lowercased != @original_name

    singularized = lowercased.singularize
    @singularized = singularized != lowercased

    @formatted_name = singularized

    # if nouns.length < 1
    #   self.note = "no nouns present"
    #   return nil
    # elsif nouns.length > 1
    #   self.note = "multiple nouns present"
    #   return nil
    # end
  end

  def original_name_key
    @original_name_key ||= SecurityToken.generate
  end

  def formatted_name_key
    @formatted_name_key ||= SecurityToken.generate
  end

  def cancel_key
    @cancel_key ||= SecurityToken.generate
  end

  def note
    "okay"
  end

  def allowed?
    !@existing_tag
  end

end