class DownloadableController < ApplicationController
  def download
    model = downloadable_model_class.find_by(id: params[:id])
    if model.present?
      disposition = params[:serve] == 'download' ? 'attachment' : 'inline'
      redirect_to cdn_link_url(file(model), params: { disposition: disposition })
    else
      route_not_found
    end
  end

  private

  def downloadable_model_class
    nil
  end

  def file(model)
    model.file
  end
end
