class ResourceFilesController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    @resource_file_types = ResourceFileType.order(:position)
    @other_resource_files = ResourceFile.where(resource_file_type_id: nil).order(:title)
  end

  def download
    resource = ResourceFile.find(params[:id])
    response.headers["Content-Disposition"] = "#{params[:serve]}; filename=\"#{resource.file.filename}\""
    response.headers["Content-Type"] = resource.file.content_type
    resource.file.download do |chunk|
      response.stream.write(chunk)
    end
  end
end
