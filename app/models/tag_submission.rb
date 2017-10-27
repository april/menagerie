# frozen_string_literal: true

class TagSubmission < ActiveRecord::Base

  belongs_to :illustration

  validates_presence_of :illustration_id
  validates_presence_of :source_ip

  attr_reader :proposed_tags

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

end