class TagSubmission < ActiveRecord::Base

  belongs_to :illustration
  before_create :assign_tags

  attr_reader :proposed_tags

  def proposed_tags=(names)
    @proposed_tags ||= begin
      current_tags = illustration.tags.pluck(:name)
      names.select(&:present?).map { |t| TagProposal.new(t, current_tags) }
    end
  end

  def create_tags!(keys)
    keys
      .map { |key| self.tags[key] }
      .compact
      .each { |name| illustration.tags << Tag.find_or_create_by(name: name) }

    self.destroy
  end

private

  def assign_tags
    self.tags = proposed_tags.reduce({}) do |memo, tag|
      if tag.allowed?
        memo[tag.original_name_key] = tag.original_name
        memo[tag.formatted_name_key] = tag.formatted_name
      end
      memo
    end
  end

end