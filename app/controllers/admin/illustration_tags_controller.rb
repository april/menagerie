class Admin::IllustrationTagsController < AdminController

  def index
    @illustration_tags = IllustrationTag.includes(:tag)
      .where("(disputed = TRUE OR verified = FALSE)")
      .order(disputed: :desc)
      .paginate(page:[params[:page].to_i, 1].max, per_page:30)
  end

  def confirm_illustration_tag
    @illustration_tag = IllustrationTag.find(params[:id])
    @illustration_tag.verified = (params[:approved] == "true")
    @illustration_tag.disputed = false

    begin
      if @illustration_tag.verified
        if params[:approved_name] != @illustration_tag.tag.name
          old_tag = @illustration_tag.tag
          @illustration_tag.tag = Tag.find_or_create_by(name: params[:approved_name])
          old_tag.destroy if old_tag.illustration_tags.count < 1
        end
        @illustration_tag.save
      else
        @illustration_tag.destroy
      end
      return render json: { success: true }, status: 200
    rescue
      return render json: { success: false }, status: 400
    end
  end

end