module Schools
  class DownloadsController < ApplicationController
    include CsvDownloader
    load_and_authorize_resource :school

    def index
    end
  end
end
