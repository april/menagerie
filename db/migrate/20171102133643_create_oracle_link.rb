class CreateOracleLink < ActiveRecord::Migration[5.1]
  def change
    create_table :oracle_links do |t|
      t.uuid :oracle_1_id, null: false
      t.uuid :oracle_2_id, null: false
      t.text :label
    end
  end
end
