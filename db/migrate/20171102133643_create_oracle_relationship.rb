class CreateOracleRelationship < ActiveRecord::Migration[5.1]
  def change
    create_table :oracle_relationships do |t|
      t.uuid :oracle_id, null: false
      t.uuid :related_id, null: false
      t.text :relationship

      t.index [:oracle_id, :related_id, :relationship], unique: true, :name => "index_oracle_relationships_on_oracle_related_relationship"
      t.index :oracle_id
      t.index :related_id
    end
  end
end
