# frozen_string_literal: true

class TaggablesController < ApplicationController

  def random
    @illustration = Illustration.includes(:tags).where(tagged: nil).order("RANDOM()").first
    @illustration = Illustration.includes(:tags).order("RANDOM()").first unless @illustration
    raise ActiveRecord::RecordNotFound unless @illustration.present?
    return redirect_to show_illustration_path(@illustration.slug)
  end

  def show
    @illustration = Illustration.includes(:content_tags, :tags).find_by(slug: params[:slug])
    raise ActiveRecord::RecordNotFound unless @illustration.present?
  end

end