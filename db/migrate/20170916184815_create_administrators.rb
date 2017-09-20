class CreateAdministrators < ActiveRecord::Migration[5.1]
  def change
    create_table :administrators, id: :uuid do |t|
    t.text :name, null: false
    t.text :email, null: false
    t.integer :lockout_strikes, default: 0, null: false
    t.text :auth_token, default: -> { "gen_random_uuid()" }, null: false
    t.text :grant_token, default: -> { "gen_random_uuid()" }, null: false
    t.datetime :grant_token_expires_at, default: -> { "now()" }, null: false
    t.datetime :unlocks_at, default: -> { "now()" }, null: false
  end
end
