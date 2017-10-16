class InitialSetup < ActiveRecord::Migration[5.1]
  def up

    create_table :tags, id: :uuid do |t|
      t.text :name, null: false
      t.text :type, null: false
      t.index [:name, :type], unique: true
      t.index :name
    end

    execute("ALTER TABLE tags ADD CONSTRAINT unique_tag_name UNIQUE (name)")

    create_table :illustrations, id: :uuid do |t|
      t.uuid :printing_id, null: false
      t.uuid :oracle_id, null: false
      t.uuid :artist_id, null: false
      t.text :slug, null: false
      t.text :name, null: false
      t.text :artist, null: false
      t.text :layout, null: false, default: "normal"
      t.text :frame, null: false
      t.text :set_code, null: false
      t.text :image_normal, null: false
      t.text :image_large, null: false
      t.boolean :tagged, null: false, default: false
      t.integer :face, null: false, default: 1
      t.index [:oracle_id, :artist_id, :face]
      t.index :slug, unique: true
    end

    create_table :oracle_cards, id: :uuid do |t|
      t.text :name, null: false
    end

    create_table :content_tags, id: :uuid do |t|
      t.uuid :tag_id, null: false
      t.uuid :taggable_id, null: false
      t.text :taggable_type, null: false
      t.integer :approval_status,  null: false, default: 1
      t.boolean :disputed, null: false, default: false
      t.text :dispute_note
      t.text :source_ip, null: false
      t.index [:taggable_id, :taggable_type]
      t.index :tag_id
    end

    create_table :tag_submissions, id: :uuid do |t|
      t.uuid :taggable_id, null: false
      t.text :taggable_type, null: false
      t.text :source_ip, null: false
      t.json :tags, null: false
      t.datetime :created_at, default: -> { "now()" }, null: false
    end

    create_table :printing_illustrations do |t|
      t.uuid :printing_id, null: false
      t.uuid :illustration_id, null: false
      t.integer :face, null: false, default: 1
    end

  end

  def down
    execute("ALTER TABLE tags DROP CONSTRAINT unique_tag_name")
    drop_table :tags
    drop_table :illustrations
    drop_table :oracle_cards
    drop_table :content_tags
    drop_table :tag_submissions
    drop_table :printing_illustrations
  end

end
