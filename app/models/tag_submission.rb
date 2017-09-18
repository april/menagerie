# frozen_string_literal: true

class TagSubmission < ActiveRecord::Base

  belongs_to :illustration

  attr_reader :proposed_tags

  def propose_tags(names)
    current_tags = illustration.tags.pluck(:name)
    @proposed_tags = names.select(&:present?).map { |n| TagProposal.new(n, current_tags) }

    self.tags = @proposed_tags.reduce({}) do |memo, tag|
      if tag.allowed?
        memo[tag.original_name_key] = tag.original_name
        memo[tag.formatted_name_key] = tag.formatted_name
      end
      memo
    end
  end

  def create_illustration_tags!(keys)
    keys
      .map { |key| self.tags[key] }.compact
      .each { |n| illustration.tags << Tag.find_or_create_by(name: n) }

    self.destroy
  end

end