class SearchController < ApplicationController

  def search
    @illustrations = []
    if params[:tag].present?
      if @tag = Tag.find_by(name: params[:tag])
        @illustrations = @tag.illustrations
      end
    elsif params[:card].present? && params[:artist].present?
      @illustrations = Illustration.where(name: params[:card], artist: params[:artist])
    elsif params[:card].present?
      @illustrations = Illustration.where(name: params[:card])
    elsif params[:artist].present?
      @illustrations = Illustration.where(artist: params[:artist])
    end

    if @illustrations.length == 1
      redirect_to show_illustration_path(@illustrations.first)
    end
  end

end