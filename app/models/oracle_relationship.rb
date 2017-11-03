# frozen_string_literal: true

class OracleRelationship < ActiveRecord::Base

  class Relationship
    SIMILAR_TO    = "similar"
    RELATED_TO    = "related"
    BETTER_THAN   = "better"
    WORSE_THAN    = "worse"
    REFERENCES    = "references"
    REFERENCED_BY = "referenced"
    COLORSHIFTED  = "colorshifted"
  end

  INVERSE_RELATIONSHIP = {
    Relationship::SIMILAR_TO    => Relationship::SIMILAR_TO,
    Relationship::RELATED_TO    => Relationship::RELATED_TO,
    Relationship::BETTER_THAN   => Relationship::WORSE_THAN,
    Relationship::WORSE_THAN    => Relationship::BETTER_THAN,
    Relationship::REFERENCES    => Relationship::REFERENCED_BY,
    Relationship::REFERENCED_BY => Relationship::REFERENCES,
    Relationship::COLORSHIFTED  => Relationship::COLORSHIFTED,
  }.freeze

  validates_presence_of :oracle_id
  validates_presence_of :related_id
  validates_inclusion_of :relationship, in: INVERSE_RELATIONSHIP.keys.freeze

  def self.create_relationship(oracle_id, related_id, relationship)
    OracleRelationship.transaction do
      self.create({
        oracle_id: related_id,
        related_id: oracle_id,
        relationship: INVERSE_RELATIONSHIP[relationship]
      })
      self.create({
        oracle_id: oracle_id,
        related_id: related_id,
        relationship: relationship
      })
    end
  end

  def destroy_relationship
    OracleRelationship.transaction do
      if inverse = self.class.find_by(oracle_id: related_id, related_id: oracle_id, relationship: INVERSE_RELATIONSHIP[relationship])
        inverse.destroy
      end
      self.destroy
    end
  end

end