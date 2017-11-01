class AddPrintingSyncColumns < ActiveRecord::Migration[5.1]
  def change
    add_column :printing_illustrations, :sync, :integer
    add_column :illustrations, :confirmed, :boolean, default: false
  end
end
