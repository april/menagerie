# frozen_string_literal: true

class Admin::IllustrationTagsController < AdminController

  def index
    @illustration_tags = IllustrationTag.includes(:illustration, :tag)
      .where("(disputed = TRUE OR approval_status = ?)", IllustrationTag::ApprovalStatus::PENDING)
      .order(disputed: :desc)
      .paginate(page:[params[:page].to_i, 1].max, per_page:30)

    # Sort results into groups by illustration,
    # disputed tags first, and disputed groups first.
    @tag_groups = @illustration_tags
      .group_by(&:illustration_id).values
      .map { |g| g.sort {|a, b| (a.disputed? ? 0 : 1) <=> (b.disputed? ? 0 : 1)} }
      .sort { |a, b| (a.first.disputed? ? 0 : 1) <=> (b.first.disputed? ? 0 : 1) }
  end

  INTENT_VALUES = {
    "approve" => IllustrationTag::ApprovalStatus::APPROVED,
    "reject" => IllustrationTag::ApprovalStatus::REJECTED,
  }.freeze

  def confirm
    @illustration_tag = IllustrationTag.find(params[:id])
    @illustration_tag.approval_status = INTENT_VALUES[params[:intent]]
    @illustration_tag.disputed = false

    begin
      if params[:tag_name] != @illustration_tag.tag.name
        old_tag = @illustration_tag.tag
        @illustration_tag.tag = Tag.find_or_create_by(name: params[:tag_name])
        old_tag.destroy if old_tag.illustration_tags.count <= 1
      end
      @illustration_tag.save

      return render json: {
        success: true,
        tag: render_to_string(template: "shared/_illustration_tag", layout: false, locals: { tag: @illustration_tag }).squish.html_safe
      }, status: 200
    rescue
      return render json: { success: false }, status: 400
    end
  end

end