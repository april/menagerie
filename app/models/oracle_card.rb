class OracleCard < ScryfallModel

  has_many :content_tags, as: :taggable
  has_many :tag_submissions, as: :taggable
  has_many :tags, through: :content_tags
  has_many :illustrations, class_name: 'Illustration', foreign_key: 'oracle_id'

  attr_accessor :slug

end