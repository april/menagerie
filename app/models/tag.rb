# frozen_string_literal: true

class Tag < ActiveRecord::Base
  has_many :content_tags

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