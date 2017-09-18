# frozen_string_literal: true

class IllustrationsController < ApplicationController

  def random
    @illustration = Illustration.includes(:tags).where(tagged: nil).order("RANDOM()").first
    @illustration = Illustration.includes(:tags).order("RANDOM()").first unless @illustration
    return redirect_to show_illustration_path(@illustration.slug)
  end

  def show
    @illustration = Illustration.includes(:illustration_tags, :tags).where(slug: params[:slug]).first
    raise ActiveRecord::RecordNotFound unless @illustration.present?
  end

end