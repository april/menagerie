# frozen_string_literal: true

class TagSubmission < ActiveRecord::Base

  belongs_to :illustration

  validates_presence_of :illustration_id
  validates_presence_of :source_ip

  attr_reader :proposed_tags
  attr_reader :proposed_relations

  def propose_tags(tag_hashes)
    tag_hashes = tag_hashes.select { |t| t[:name].present? }
    names = tag_hashes.map { |t| t[:name].strip.squish }

    # Format illustration-specific tags with these names into a lookup
    current_tags = illustration.tags.pluck(:name)
    current_tags = Hash[current_tags.map(&:downcase).zip(current_tags)]

    # Format existing tags with these names into a lookup
    existing_tags = Tag.where(name: (names + names.map(&:downcase)).uniq).pluck(:name)
    existing_tags = Hash[existing_tags.map(&:downcase).zip(existing_tags)]

    # Generate tag proposals
    @proposed_tags = tag_hashes.map { |t| TagProposal.new(t, current_tags[t[:name].downcase], existing_tags[t[:name].downcase]) }

    self.tags = @proposed_tags.reduce({}) do |memo, tag|
      if tag.allowed?
        memo[tag.original_name_key] = tag.original_tag_store if tag.allow_original_name?
        memo[tag.formatted_name_key] = tag.formatted_tag_store
      end
      memo
    end
  end

  RELATED_BIND_PATTERN = "(oracle_id = ? AND related_id = ? AND relationship = ?)"

  def propose_related(rel_hashes)
    rel_hashes = rel_hashes.select { |r| r[:name].present? }
    return @proposed_relations = [] unless rel_hashes.present?

    # Fetch all related cards, and assign them to their respective hash
    # This should use where lookup from OracleCards table (which is missing)
    related_cards = Illustration.where(name: rel_hashes.map { |h| h[:name] }.map(&:strip).map(&:squish))
    rel_hashes.each { |r| r[:related_card] = related_cards.detect { |c| r[:name] == c.name } }
    rel_hashes = rel_hashes.select { |r| r[:related_card].present? }
    return @proposed_relations = [] unless rel_hashes.present?

    # Fetch all existing relationships
    bind_pattern = Array.new(rel_hashes.count, RELATED_BIND_PATTERN).join(" OR ")
    bind_args = rel_hashes.map { |r| [illustration.oracle_id, r[:related_card].oracle_id, r[:type]] }
    existing_relations = OracleRelationship.where(bind_pattern, *bind_args.flatten)
    rel_hashes.each do|r|
      r[:oracle_relationship] = existing_relations.detect { |o|
        o.oracle_id == illustration.oracle_id &&
        o.related_id == r[:related_card].oracle_id &&
        o.relationship == r[:type]
      }
    end

    @proposed_relations = rel_hashes.map { |r| RelationProposal.new(r, illustration) }
  end

  def create_content_tags!(keys)
    keys
      .map { |key| self.tags[key] }.compact
      .each do |tag_store|
        ContentTag.create({
          source_ip: source_ip,
          illustration: illustration,
          oracle_id: (tag_store["oracle"] ? illustration.oracle_id : nil),
          tag: Tag.find_or_create_by(name: tag_store["name"]),
        }.compact)
      end

    self.destroy
  end

  def permitted?
    # @tag_submission.proposed_tags.reject(&:duplicate?).any?
    true
  end

  def error_message
    "boo"
  end

end