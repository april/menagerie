# frozen_string_literal: true

class Admin::ContentTagsController < AdminController

  def approve
    @content_tags = ContentTag.includes(:illustration, :tag)
      .where("(disputed = TRUE OR approval_status = ?)", ContentTag::ApprovalStatus::PENDING)
      .order(disputed: :desc)
      .paginate(page:[params[:page].to_i, 1].max, per_page:200)

    # Sort results into groups by illustration,
    # disputed tags first, and disputed groups first.
    @tag_groups = @content_tags
      .group_by(&:illustration_id).values
      .map { |g| g.sort {|a, b| (a.disputed? ? 0 : 1) <=> (b.disputed? ? 0 : 1)} }
      .sort { |a, b| (a.first.disputed? ? 0 : 1) <=> (b.first.disputed? ? 0 : 1) }
  end

  def confirm
    @content_tag = ContentTag.find(params[:id])
    @content_tag.approval_status = confirm_params[:intent].to_i
    @content_tag.disputed = false

    begin
      # Destroy rejected tags
      if @content_tag.rejected?
        tag = @content_tag.tag
        tag.destroy if tag.content_tags.count <= 1
        @content_tag.destroy

      # Reconfigure renamed tags
      elsif confirm_params[:name] != @content_tag.name || confirm_params[:type] != @content_tag.type
        tag = @content_tag.tag
        @content_tag.tag = Tag.find_or_create_by(name: confirm_params[:name])
        @content_tag.oracle_id = (confirm_params[:type] == ContentTag::Type::ORACLE_CARD) ? @content_tag.illustration.oracle_id : nil
        @content_tag.save
        tag.destroy if tag.content_tags.count < 1

      # Or else just save
      else
        @content_tag.save
      end

      return render json: {
        success: true,
        tag: render_to_string(template: "shared/_content_tag", layout: false, locals: { tag: @content_tag }).squish.html_safe
      }, status: 200
    rescue
      return render json: { success: false }, status: 400
    end
  end

private

  def confirm_params
    params.require(:tag).permit(:name, :type, :intent)
  end

end