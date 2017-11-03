# frozen_string_literal: true

class TagSubmission < ActiveRecord::Base

  belongs_to :illustration

  validates_presence_of :illustration_id
  validates_presence_of :source_ip

  before_save :set_tags

  def proposed_tags
    @proposed_tags ||= []
  end

  def propose_tags(form_data)
    form_data = form_data.select { |t| t[:name].present? }
    names = form_data.map { |t| t[:name].strip.squish }
    return unless form_data.present?

    # Format illustration-specific tags with these names into a lookup
    current_tags = illustration.tags.pluck(:name)
    current_tags = Hash[current_tags.map(&:downcase).zip(current_tags)]

    # Format existing tags with these names into a lookup
    existing_tags = Tag.where(name: (names + names.map(&:downcase)).uniq).pluck(:name)
    existing_tags = Hash[existing_tags.map(&:downcase).zip(existing_tags)]

    # Add tag proposals
    form_data.each { |t| proposed_tags << TagProposal.new(t, current_tags[t[:name].downcase], existing_tags[t[:name].downcase]) }
  end

  RELATED_BIND_PATTERN = "(oracle_id = ? AND related_id = ? AND relationship = ?)"

  def propose_related(form_data)
    form_data = form_data.select { |r| r[:name].present? }
    return unless form_data.present?

    # Fetch all related cards, and assign them to their respective hash
    # This should use where lookup from OracleCards table (which is missing)
    related_cards = Illustration.where(name: form_data.map { |h| h[:name] }.map(&:strip).map(&:squish))
    form_data.each { |r| r[:related_card] = related_cards.detect { |c| r[:name] == c.name } }
    form_data = form_data.select { |r| r[:related_card].present? }
    return unless form_data.present?

    # Fetch all existing relationships
    bind_pattern = Array.new(form_data.count, RELATED_BIND_PATTERN).join(" OR ")
    bind_args = form_data.map { |r| [illustration.oracle_id, r[:related_card].oracle_id, r[:type]] }
    existing_relations = OracleRelationship.where(bind_pattern, *bind_args.flatten)
    form_data.each do|r|
      r[:oracle_relationship] = existing_relations.detect { |o|
        o.oracle_id == illustration.oracle_id &&
        o.related_id == r[:related_card].oracle_id &&
        o.relationship == r[:type]
      }
    end

    form_data.each { |r| proposed_tags << RelationProposal.new(r, illustration) }
  end

  def create_content_tags!(keys)
    keys
      .map { |key| self.tags[key] }.compact
      .each do |params|
        case params["model"]
        when ContentTag.name
          create_content_tag(params)
        when OracleRelationship.name
          create_oracle_relationship(params)
        end
      end

    self.destroy
  end

  def submission_error
    @error_message ||= if !proposed_tags.reject(&:duplicate?).present?
      "no new tags or relationships were proposed"
    end
  end

  def invalid?
    submission_error.present?
  end

private

  def set_tags
    self.tags = proposed_tags.reduce({}) do |memo, tag|
      if tag.allowed?
        memo[tag.original_name_key] = tag.original_tag_store if tag.allow_original_name?
        memo[tag.formatted_name_key] = tag.formatted_tag_store
      end
      memo
    end
  end

  def create_content_tag(params)
    ContentTag.create({
      source_ip: source_ip,
      illustration: illustration,
      oracle_id: (params["oracle"] ? illustration.oracle_id : nil),
      tag: Tag.find_or_create_by(name: params["name"]),
    }.compact)
  end

  def create_oracle_relationship(params)
    OracleRelationship.create_relationship(
      oracle_id: params["oracle_id"],
      related_id: params["related_id"],
      relationship: params["relationship"]
    )
  end

end