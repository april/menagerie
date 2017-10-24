# frozen_string_literal: true

class ContentTag < ActiveRecord::Base

  belongs_to :tag
  belongs_to :illustration

  class ApprovalStatus
    PENDING  = 1
    APPROVED = 2
    REJECTED = 3
  end

  validates_presence_of :taggable_id
  validates_presence_of :taggable_type
  validates_presence_of :tag_id
  validates_presence_of :source_ip
  validates_inclusion_of :approval_status, :in => [
    ApprovalStatus::PENDING,
    ApprovalStatus::APPROVED,
  ].freeze

  scope :pending, -> { where(approval_status: ApprovalStatus::PENDING) }
  scope :approved, -> { where(approval_status: ApprovalStatus::APPROVED) }

  def after_initialize
    if new_record?
      self.approval_status = ApprovalStatus::PENDING
      self.disputed = false
    end
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
    disputed
  end

  def hidden?
    rejected? || (disputed? && pending?)
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

  def search_uri
    if oracle_id.present?
      return $routes.search_path(type: "oracle", q: tag.name)
    else
      return $routes.search_path(type: "illustration", q: tag.name)
    end
  end

end