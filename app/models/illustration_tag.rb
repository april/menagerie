# frozen_string_literal: true

class IllustrationTag < ActiveRecord::Base

  belongs_to :illustration
  belongs_to :tag

  class ApprovalStatus
    PENDING  = 1
    APPROVED = 2
    REJECTED = 3
  end

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

  def pending?
    approval_status == ApprovalStatus::PENDING
  end

  def approved?
    approval_status == ApprovalStatus::APPROVED
  end

  def rejected?
    approval_status == ApprovalStatus::REJECTED
  end

end