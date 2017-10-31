class RemoveOracleCards < ActiveRecord::Migration[5.1]
  def change
    drop_table :oracle_cards
  end
end
