class CreatePrintingIllustrations < ActiveRecord::Migration[5.1]
  def change
    create_table :printing_illustrations do |t|
      t.uuid :printing_id, null: false
      t.uuid :illustration_id, null: false
      t.integer :face, null: false, default: 1
    end
  end
end
