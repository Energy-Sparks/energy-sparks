class ResourceFilesController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    @resource_files = ResourceFile.order(:title)
  end
end
