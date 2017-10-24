class UpdateContentTags < ActiveRecord::Migration[5.1]
  def change
    # Content Tags
    remove_index  :content_tags, column: [:taggable_id, :taggable_type]
    remove_column :content_tags, :taggable_type
    rename_column :content_tags, :taggable_id, :illustration_id
    add_column    :content_tags, :oracle_id, :uuid
    add_index     :content_tags, :oracle_id

    # Tags
    remove_index  :tags, column: [:name, :type]
    remove_column :tags, :type

    # Tag Submissions
    remove_column :tag_submissions, :taggable_type
    rename_column :tag_submissions, :taggable_id, :illustration_id
  end
end
