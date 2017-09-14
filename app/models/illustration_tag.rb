class IllustrationTag < ActiveRecord::Base

  belongs_to :illustration
  belongs_to :tag

  def name
    tag.name
  end

  def status
    return "approved" if verified?
    return "disputed" if disputed?
    return "pending"
  end

end