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

ActiveRecord::Schema.define(version: 20170916184815) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "administrators", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.text "email", null: false
    t.integer "lockout_strikes", default: 0, null: false
    t.text "auth_token", default: -> { "gen_random_uuid()" }, null: false
    t.text "grant_token", default: -> { "gen_random_uuid()" }, null: false
    t.datetime "grant_token_expires_at", default: -> { "now()" }, null: false
    t.datetime "unlocks_at", default: -> { "now()" }, null: false
  end

  create_table "illustration_tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "illustration_id", null: false
    t.uuid "tag_id", null: false
    t.boolean "approved", default: false, null: false
    t.boolean "disputed", default: false, null: false
    t.text "dispute_note", null: false
    t.index ["illustration_id"], name: "index_illustration_tags_on_illustration_id"
    t.index ["tag_id"], name: "index_illustration_tags_on_tag_id"
  end

  create_table "illustrations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.text "artist", null: false
    t.text "slug", null: false
    t.text "image_normal_uri", null: false
    t.text "image_large_uri", null: false
    t.text "image_crop_uri"
    t.boolean "tagged", default: false, null: false
    t.index ["name", "artist"], name: "index_illustrations_on_name_and_artist", unique: true
    t.index ["slug"], name: "index_illustrations_on_slug", unique: true
  end

  create_table "tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

end
