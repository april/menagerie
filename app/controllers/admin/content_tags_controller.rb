# frozen_string_literal: true

class Admin::ContentTagsController < AdminController

  def approve_illustrations
    load_approval_data(Illustration.name)
    render :approve
  end

  def approve_oracle_cards
    load_approval_data(OracleCard.name)
    render :approve
  end

  INTENT_VALUES = {
    "approve" => ContentTag::ApprovalStatus::APPROVED,
    "reject" => ContentTag::ApprovalStatus::REJECTED,
  }.freeze

  def confirm
    @content_tag = ContentTag.find(params[:id])
    @content_tag.approval_status = INTENT_VALUES[params[:intent]]
    @content_tag.disputed = false

    begin
      if params[:tag_name] != @content_tag.tag.name
        old_tag = @content_tag.tag
        @content_tag.tag = Tag.find_or_create_by(name: params[:tag_name], type: @content_tag.taggable_type)
        old_tag.destroy if old_tag.content_tags.count <= 1
      end
      @content_tag.save

      return render json: {
        success: true,
        tag: render_to_string(template: "shared/_content_tag", layout: false, locals: { tag: @content_tag }).squish.html_safe
      }, status: 200
    rescue
      return render json: { success: false }, status: 400
    end
  end

private

  def load_approval_data(type)
    @content_type = type
    @content_tags = ContentTag.includes(:taggable, :tag)
      .where(taggable_type: type)
      .where("(disputed = TRUE OR approval_status = ?)", ContentTag::ApprovalStatus::PENDING)
      .order(disputed: :desc)
      .paginate(page:[params[:page].to_i, 1].max, per_page:30)

    # Assign representitive illustrations for each oracle card
    if type == OracleCard.name
      OracleCard.assign_illustrations(@content_tags.collect(&:taggable))
    end

    # Sort results into groups by illustration,
    # disputed tags first, and disputed groups first.
    @tag_groups = @content_tags
      .group_by(&:taggable_id).values
      .map { |g| g.sort {|a, b| (a.disputed? ? 0 : 1) <=> (b.disputed? ? 0 : 1)} }
      .sort { |a, b| (a.first.disputed? ? 0 : 1) <=> (b.first.disputed? ? 0 : 1) }
  end

end