# frozen_string_literal: true

class Admin::TagsController < AdminController

  def index
    @page = [params[:page].to_i, 1].max
    @tags = Tag.order('lower(name)').paginate(page: @page, per_page:300)
  end

end