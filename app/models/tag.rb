class Tag < ActiveRecord::Base

  self.inheritance_column = nil

  has_many :content_tags
  has_many :illustrations, through: :content_tags
  has_many :oracle_cards, through: :content_tags

  validates_presence_of :name
  validates_presence_of :type

  # Duck-type with ContentTag
  # Allows Tag to be rendered interchangably

  def status
    "approved"
  end

  def disputed?
    false
  end

  def hidden?
    false
  end

  def pending?
    false
  end

  def approved?
    true
  end

  def rejected?
    false
  end

end