class IllustrationTag < ActiveRecord::Base

  belongs_to :illustration
  belongs_to :tag

  def name
    tag.name
  end

  def status
    return "disputed" if disputed?
    return "approved" if approved?
    return "pending"
  end

end