# frozen_string_literal: true

class PagesController < ApplicationController

  def home
    @illustration_tags = Tag.order("RANDOM()").take(12)
  end

  def guide
  end

  def tos
  end

  def privacy
  end

end