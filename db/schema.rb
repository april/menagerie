# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170912124837) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"
  enable_extension "postgres_fdw"

  create_table "administrators", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.text "email", null: false
    t.integer "lockout_strikes", default: 0, null: false
    t.text "auth_token", default: -> { "gen_random_uuid()" }, null: false
    t.text "grant_token", default: -> { "gen_random_uuid()" }, null: false
    t.datetime "grant_token_expires_at", default: -> { "now()" }, null: false
    t.datetime "unlocks_at", default: -> { "now()" }, null: false
  end

  create_table "content_tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tag_id", null: false
    t.uuid "taggable_id", null: false
    t.text "taggable_type", null: false
    t.integer "approval_status", default: 1, null: false
    t.boolean "disputed", default: false, null: false
    t.text "dispute_note"
    t.text "source_ip", null: false
    t.index ["tag_id"], name: "index_content_tags_on_tag_id"
    t.index ["taggable_id", "taggable_type"], name: "index_content_tags_on_taggable_id_and_taggable_type"
  end

  create_table "illustrations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "printing_id", null: false
    t.uuid "oracle_id", null: false
    t.uuid "artist_id", null: false
    t.text "slug", null: false
    t.text "name", null: false
    t.text "artist", null: false
    t.text "layout", default: "normal", null: false
    t.text "frame", null: false
    t.text "set_code", null: false
    t.text "image_normal", null: false
    t.text "image_large", null: false
    t.boolean "tagged", default: false, null: false
    t.integer "face", default: 1, null: false
    t.index ["oracle_id", "artist_id", "face"], name: "index_illustrations_on_oracle_id_and_artist_id_and_face"
    t.index ["slug"], name: "index_illustrations_on_slug", unique: true
  end

  create_table "oracle_cards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
  end

  create_table "printing_illustrations", force: :cascade do |t|
    t.uuid "printing_id", null: false
    t.uuid "illustration_id", null: false
    t.integer "face", default: 1, null: false
  end

  create_table "tag_submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "taggable_id", null: false
    t.text "taggable_type", null: false
    t.text "source_ip", null: false
    t.json "tags", null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
  end

  create_table "tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.text "type", null: false
    t.index ["name", "type"], name: "index_tags_on_name_and_type", unique: true
    t.index ["name"], name: "index_tags_on_name"
    t.index ["name"], name: "unique_tag_name", unique: true
  end

end
