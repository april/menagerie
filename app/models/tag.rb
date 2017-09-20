class Tag < ActiveRecord::Base

  has_many :illustration_tags
  has_many :illustrations, through: :illustration_tags

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