class TagsController < ApplicationController

  def dispute
    @illustration_tag = IllustrationTag.find(params[:button])
    @illustration_tag.update_attributes(disputed: true)
    redirect_to show_illustration_path(@illustration_tag.illustration)
  end

  def approve
    id = params.dig(:tagging, :illustration_id)
    if @illustration_tag = IllustrationTag.find_by(illustration_id: id, tag_id: params[:button])
      @illustration_tag.update_attributes(verified: true)
      redirect_to show_illustration_path(@illustration_tag.illustration)
    end
  end

end