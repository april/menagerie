class InitialSetup < ActiveRecord::Migration[5.1]
  def change

    create_table :tags, id: :uuid do |t|
      t.text :name, null: false
      t.index :name, unique: true
    end

    create_table :illustrations, id: :uuid do |t|
      t.text :name, null: false
      t.text :artist, null: false
      t.text :slug, null: false
      t.text :image_normal_uri, null: false
      t.text :image_large_uri, null: false
      t.text :image_crop_uri
      t.boolean :tagged, null: false, default: false
      t.index :slug, unique: true
      t.index [:name, :artist], unique: true
    end

    create_table :illustration_tags, id: :uuid do |t|
      t.uuid :illustration_id, null: false
      t.uuid :tag_id, null: false
      t.integer :approval_status,  null: false, default: 1
      t.boolean :disputed, null: false, default: false
      t.text :dispute_note
      t.text :source_ip, null: false
      t.index :illustration_id
      t.index :tag_id
    end

  end
end
