class ResourceFilesController < ApplicationController
  include StorageHelper
  skip_before_action :authenticate_user!
  def index
    @resource_file_types = ResourceFileType.order(:position)
    @other_resource_files = ResourceFile.where(resource_file_type_id: nil).order(:title)
  end

  def download
    resource = ResourceFile.find_by(id: params[:id])
    if resource.present?
      serve_from_storage(resource.file, params[:serve])
    else
      render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
    end
  end
end
