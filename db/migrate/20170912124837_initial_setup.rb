class InitialSetup < ActiveRecord::Migration[5.1]
  def change

    create_table :tags, id: :uuid do |t|
      t.string :name, null: false
      t.index :name, unique: true
    end

    create_table :illustrations, id: :uuid do |t|
      t.string :name, null: false
      t.string :artist, null: false
      t.string :slug, null: false
      t.string :image_normal_uri, null: false
      t.string :image_large_uri, null: false
      t.string :image_crop_uri, null: false
      t.boolean :tagged, null: false, default: false
      t.index :slug, unique: true
      t.index [:name, :artist], unique: true
    end

    create_table :illustration_tags do |t|
      t.integer :illustration_id, null: false
      t.integer :tag_id, null: false
      t.boolean :approved, null: false, default: false
      t.boolean :disputed, null: false, default: false
      t.text :dispute_note, null: false
      t.index :illustration_id
      t.index :tag_id
    end

  end
end
