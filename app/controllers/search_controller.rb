class SearchController < ApplicationController

  def search
    criteria = {
      name: params[:card].presence,
      artist: params[:artist].presence
    }.compact

    paginate = {
      page: [params[:page].to_i, 1].max,
      per_page: 30
    }

    @has_query = params.key?(:tag) || params.key?(:card) || params.key?(:artist)

    if params[:tag].present? && @tag = Tag.find_by(name: params[:tag])
      @illustrations = @tag.illustrations.where(criteria).paginate(paginate)
    elsif criteria.any?
      @illustrations = Illustration.where(criteria).paginate(paginate)
    else
      @illustrations = []
    end

    if @illustrations.length == 1
      redirect_to show_illustration_path(@illustrations.first)
    end
  end

end