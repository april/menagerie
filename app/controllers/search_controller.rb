# frozen_string_literal: true

class SearchController < ApplicationController

  ORACLE_TAG_SQL = %{
    SELECT DISTINCT ON (oracle_id) * FROM illustrations
    WHERE oracle_id IN (
      SELECT taggable_id FROM content_tags
      WHERE taggable_type = 'OracleCard' AND tag_id = ?
    )
  }.squish.freeze

  def search
    paginate = {
      page: [params[:page].to_i, 1].max,
      per_page: 30
    }

    case params[:type]
    when "oracle"
      @tag = OracleCardTag.find_by(name: params[:q])
      @results = Illustration.paginate_by_sql([ORACLE_TAG_SQL, @tag.id], paginate) if @tag
    when "illustration"
      @tag = IllustrationTag.find_by(name: params[:q])
      @results = @tag.taggables.paginate(paginate) if @tag
    when "card"
      @results = Illustration.where(name: params[:q]).order(:artist).paginate(paginate)
    when "artist"
      @results = Illustration.where(artist: params[:q]).paginate(paginate)
    end

    @results ||= []

    if @results.length == 1
      return redirect_to show_illustration_path(@results.first.slug) if params[:type] =~ /illustration|card|artist/
      return redirect_to show_oracle_card_path(@results.first.slug) if params[:type] =~ /oracle/
    end
  end

  def autocomplete
    if params[:illustration].present?
      return render json: IllustrationTag.where("name ILIKE ?", "#{params[:illustration]}%").distinct.pluck(:name)
    elsif params[:oracle].present?
      return render json: OracleCardTag.where("name ILIKE ?", "#{params[:oracle]}%").distinct.pluck(:name)
    elsif params[:card].present?
      return render json: Illustration.where("name ILIKE ?", "#{params[:card]}%").distinct.pluck(:name)
    elsif params[:artist].present?
      return render json: Illustration.where("artist ILIKE ?", "#{params[:artist]}%").distinct.pluck(:artist)
    end
  end

end