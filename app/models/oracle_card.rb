# frozen_string_literal: true

class OracleCard < ActiveRecord::Base

  has_many :illustrations, class_name: "Illustration", foreign_key: "oracle_id"

  attr_accessor :slug
  attr_accessor :illustration

  def self.assign_illustrations(oracle_cards)
    illustrations = Illustration.select("DISTINCT ON (oracle_id) *").where(oracle_id: oracle_cards.map(&:id).uniq)
    oracle_cards.each do |c|
      c.illustration = illustrations.detect { |i| i.oracle_id == c.id }
      c.slug = c.illustration.slug
    end
  end

  def search_type
    "oracle"
  end

end