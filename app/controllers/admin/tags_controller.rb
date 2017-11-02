# frozen_string_literal: true

class Admin::TagsController < AdminController

  def index
    @page = [params[:page].to_i, 1].max
    @tags = Tag.order('lower(name)').paginate(page: @page, per_page:300)
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def update
    @tag = Tag.find(params[:id])
    if @tag.update_attributes(tag_update_params)
      flash[:notice] = %Q(Tag "#{@tag.name}" was successfully updated)
      return redirect_to admin_tags_index_path
    else
      flash[:notice] = %Q(Error updating tag)
      render :edit
    end
  end

  REMOVE_DUPLICATES_SQL = %{
    DELETE FROM content_tags
    WHERE id IN (
      SELECT id FROM (
        SELECT id, ROW_NUMBER()
        OVER (partition BY tag_id, illustration_id) AS rnum
        FROM content_tags
        WHERE tag_id = ?
      ) t
      WHERE t.rnum > 1
    )
  }.squish.freeze

  def merge
    @tag = Tag.find(params[:id])
    @target = Tag.find_by(name: tag_merge_params[:name])

    if @target.present?
      c = ActiveRecord::Base.connection
      Tag.connection.execute("UPDATE content_tags SET tag_id = #{c.quote(@target.id)} WHERE tag_id = #{c.quote(@tag.id)}")
      Tag.connection.execute(REMOVE_DUPLICATES_SQL.sub('?', c.quote(@target.id)))
      @tag.destroy
      flash[:notice] = %Q(Tag was successfully merged)
      return redirect_to admin_tags_index_path
    else
      flash[:notice] = %Q(Invalid tag target)
      render :edit
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    if @tag.destroy
      flash[:notice] = %Q(Tag "#{@tag.name}" was deleted)
      return redirect_to admin_tags_index_path
    else
      flash[:notice] = %Q(Error deleting tag)
      return redirect_to admin_edit_tag_path(@tag.id)
    end
  end

private

  def tag_update_params
    params.require(:tag_update).permit(:name)
  end

  def tag_merge_params
    params.require(:tag_merge).permit(:name)
  end
end