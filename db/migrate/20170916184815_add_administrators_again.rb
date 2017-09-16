class AddAdministratorsAgain < ActiveRecord::Migration[5.1]
  def up
    create_table :administrators, id: :uuid do |t|
      t.text :name, null:false
      t.text :email, null:false
      t.integer :lockout_strikes, default: 0, null: false
    end

    execute("ALTER TABLE administrators ADD COLUMN auth_token text DEFAULT uuid_generate_v4() NOT NULL")
    execute("ALTER TABLE administrators ADD COLUMN grant_token text DEFAULT uuid_generate_v4() NOT NULL")
    execute("ALTER TABLE administrators ADD COLUMN grant_token_expires_at timestamp with time zone DEFAULT now() NOT NULL")
    execute("ALTER TABLE administrators ADD COLUMN unlocks_at timestamp with time zone DEFAULT now() NOT NULL")
  end

  def down
    drop_table :administrators
  end
end
