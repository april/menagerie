# frozen_string_literal: true

class TaggablesController < ApplicationController

  def random
    @illustration = Illustration.includes(:tags).where(tagged: nil).order("RANDOM()").first
    @illustration = Illustration.includes(:tags).order("RANDOM()").first unless @illustration
    raise ActiveRecord::RecordNotFound unless @illustration.present?
    return redirect_to show_illustration_path(@illustration.slug)
  end

  def illustration
    @illustration = Illustration.includes(:content_tags, :tags).find_by(slug: params[:slug])
    raise ActiveRecord::RecordNotFound unless @illustration.present?
  end

  def oracle_card
    @illustration = Illustration.find_by(slug: params[:slug])
    raise ActiveRecord::RecordNotFound unless @illustration.present?

    @oracle_card = OracleCard.includes(:content_tags, :tags).find(@illustration.oracle_id)
    @oracle_card.illustration = @illustration
    @oracle_card.slug = @illustration.slug
  end

end