class TagsController < ApplicationController
  def index
    @tags = Tag.find(:all)
  end

  def show
    @tag = Tag.find(params[:id])
    @notes = Note.find_tagged_with(@tag)
  end
end
