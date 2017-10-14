# frozen_string_literal: true

class OracleCard < ActiveRecord::Base

  self.table_name = "#{ENV.fetch('SCRYFALL_DATABASE_SERVER')}.oracle_cards"

  has_many :content_tags, as: :taggable
  has_many :tag_submissions, as: :taggable
  has_many :tags, through: :content_tags
  has_many :illustrations, class_name: 'Illustration', foreign_key: 'oracle_id'

  attr_accessor :slug
  attr_accessor :illustration

  def self.assign_illustrations(oracle_cards)
    illustrations = Illustration.select('DISTINCT ON (oracle_id) *').where(oracle_id: oracle_cards.map(&:id).uniq)
    oracle_cards.each { |c| c.illustration = illustrations.detect { |i| i.oracle_id == c.id } }
  end

  def tag_model
    return OracleCardTag
  end

  def search_type
    "oracle"
  end

end