# frozen_string_literal: true

class RelationProposal < TagProposal

  VALID_TYPES = OracleRelationship::INVERSE_RELATIONSHIP.keys.freeze

  def initialize(opts, card=nil)
    @original_name = opts.fetch(:name)
    @formatted_name = opts.fetch(:name)
    @type = opts.fetch(:type, VALID_TYPES[0]).strip.squish
    @card = card
    @related_card = opts[:related_card]
    @oracle_relationship = opts[:oracle_relationship]

    @omit = false
    @duplicate = false
    @suggest_cancel = false
    @notes = []

    [
      :check_related!,
      :check_selfjoin!,
      :check_type!,
      :check_existing!,
    ].each { |method| return self if self.send(method) }
  end

  def type_short
    @type
  end

  def allow_original_name?
    false
  end

private

  def check_related!
    if !@related_card
      @omit = true
      @suggest_cancel = true
      @notes << "card not found"
      return true
    end
    return false
  end

  def check_selfjoin!
    if @card.oracle_id == @related_card.oracle_id
      @omit = true
      @suggest_cancel = true
      @notes << "cannot reference itself"
      return true
    end
    return false
  end

  def check_type!
    if !VALID_TYPES.include?(@type)
      @omit = true
      @suggest_cancel = true
      @notes << "invalid relationship type"
      return true
    end
    return false
  end

  def check_existing!
    if @oracle_relationship.present?
      @duplicate = true
      @omit = true
      @notes << "existing relationship"
      return true
    end
    return false
  end

end