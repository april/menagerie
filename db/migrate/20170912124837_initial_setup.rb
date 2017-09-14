class InitialSetup < ActiveRecord::Migration[5.1]
  def change

    create_table :tags do |t|
      t.string :name, null: false
      t.index :name, unique: true
    end

    create_table :illustrations do |t|
      t.string :name, null: false
      t.string :artist, null: false
      t.string :image_uri, null: false
      t.boolean :tagged, null: false, default: false
      t.index [:name, :artist], unique: true
    end

    create_table :illustration_tags do |t|
      t.integer :illustration_id, null: false
      t.integer :tag_id, null: false
      t.boolean :disputed, null: false, default: false
      t.boolean :verified, null: false, default: false
      t.index :illustration_id
      t.index :tag_id
    end

  end
end
