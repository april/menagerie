class AddPrintingSyncColumns < ActiveRecord::Migration[5.1]
  def change
    add_column :printing_illustrations, :sync, :timestamp
    add_column :illustrations, :confirmed, :boolean, default: false
  end
end
