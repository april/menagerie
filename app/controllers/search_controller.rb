# frozen_string_literal: true

class SearchController < ApplicationController

  def search
    paginate = {
      page: [params[:page].to_i, 1].max,
      per_page: 30
    }

    case params[:type]
    when "tag"
      @tag = Tag.find_by(name: params[:q])
      @results = @tag.illustrations.paginate(paginate) if @tag
    when "card"
      @results = Illustration.where(name: params[:q]).order(:artist).paginate(paginate)
    when "artist"
      @results = Illustration.where(artist: params[:q]).paginate(paginate)
    end

    @results ||= []

    if @results.length == 1
      return redirect_to show_illustration_path(@results.first.slug)
    end
  end

  def autocomplete
    if params[:tag].present?
      return render json: Tag.where("name ILIKE ?", "#{params[:tag]}%").distinct.pluck(:name)
    elsif params[:card].present?
      return render json: Illustration.where("name ILIKE ?", "#{params[:card]}%").distinct.pluck(:name)
    elsif params[:artist].present?
      return render json: Illustration.where("artist ILIKE ?", "#{params[:artist]}%").distinct.pluck(:artist)
    end
  end

end