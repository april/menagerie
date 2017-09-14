class HomepageController < ApplicationController

  def index
  end

  def tag
    @tag = Tag.find_by(name: params[:name])
  end
end