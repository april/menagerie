# frozen_string_literal: true

class TagSubmission < ActiveRecord::Base

  belongs_to :taggable, polymorphic: true

  validates_presence_of :taggable_id
  validates_presence_of :taggable_type
  validates_presence_of :source_ip

  attr_reader :proposed_tags

  def propose_tags(names)
    # Format the provided names for matching:
    names = names.select(&:present?).map(&:strip).map(&:squish)

    # Format illustration-specific tags with these names into a lookup
    current_tags = taggable.tags.pluck(:name)
    current_tags = Hash[current_tags.map(&:downcase).zip(current_tags)]

    # Format existing tags with these names into a lookup
    defined_tags = Tag.where(name: (names + names.map(&:downcase)).uniq, type: taggable_type).pluck(:name)
    defined_tags = Hash[defined_tags.map(&:downcase).zip(defined_tags)]

    # Generate tag proposals
    @proposed_tags = names.map { |n| TagProposal.new(n, current_tags[n.downcase], defined_tags[n.downcase]) }

    self.tags = @proposed_tags.reduce({}) do |memo, tag|
      if tag.allowed?
        memo[tag.original_name_key] = tag.original_name
        memo[tag.formatted_name_key] = tag.formatted_name
      end
      memo
    end
  end

  def create_content_tags!(keys)
    keys
      .map { |key| self.tags[key] }.compact
      .each do |n|
        tag = Tag.find_or_create_by(name: n, type: taggable_type)
        ContentTag.create(taggable: taggable, tag: tag, source_ip: source_ip)
      end

    self.destroy
  end

end