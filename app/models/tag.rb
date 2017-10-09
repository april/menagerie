class Tag < ActiveRecord::Base

  has_many :content_tags
  has_many :illustrations, through: :content_tags
  has_many :oracle_cards, through: :content_tags

  validates_presence_of :name

  def status
    "approved"
  end

  def disputed?
    false
  end

  def disputed?
    false
  end

  def disputed?
    false
  end

end