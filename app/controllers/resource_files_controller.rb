class ResourceFilesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @resource_file_types = ResourceFileType.order(:position)
    @other_resource_files = ResourceFile.where(resource_file_type_id: nil).order(:title)
  end

  def download
    resource = ResourceFile.find_by(id: params[:id])
    if resource.present?
      disposition = params[:serve] == 'download' ? 'attachment' : 'inline'
      redirect_to cdn_link_url(resource.file, params: { disposition: disposition })
    else
      route_not_found
    end
  end
end
