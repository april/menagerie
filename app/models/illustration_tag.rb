# frozen_string_literal: true

class IllustrationTag < ActiveRecord::Base

  belongs_to :illustration
  belongs_to :tag

  def name
    tag.name
  end

  def status
    return "disputed" if disputed?
    return "rejected" if rejected?
    return "approved" if approved?
    return "pending"
  end

  def disputed?
    self.disputed
  end

  def rejected?
    approved == false
  end

  def approved?
    approved == true
  end

end