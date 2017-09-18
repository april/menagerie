class CreateTagSubmissions < ActiveRecord::Migration[5.1]
  def change
    create_table :tag_submissions, id: :uuid do |t|
      t.uuid :illustration_id, null: false
      t.json :tags, null: false
      t.datetime :created_at, default: -> { "now()" }, null: false
    end
  end
end
