# frozen_string_literal: true

class OracleLink < ActiveRecord::Base

  def self.create_link(id1, id2, label)
    ids = [id1, id2].sort
    params = { oracle_1_id: ids[0], oracle_2_id: ids[1] }
    self.where(params).first_or_create(params.merge(label: label))
  end

  def self.where_oracle_id(id)
    self.where("oracle_1_id = ? OR oracle_2_id = ?", id, id)
  end

end