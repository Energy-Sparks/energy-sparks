module Admin
  class VideosController < AdminController
    load_and_authorize_resource

    def index
      @videos = Video.order(:title)
    end

    def show
    end

    def new
    end

    def edit
    end

    def create
      if @video.save
        redirect_to admin_videos_path, notice: 'Video was successfully created.'
      else
        render :new
      end
    end

    def update
      if @video.update(video_params)
        redirect_to admin_videos_path, notice: 'Video was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @video.destroy
      redirect_to admin_videos_path, notice: 'Video was successfully deleted.'
    end

    private

    def video_params
      params.require(:video).permit(:youtube_id, :title, :description, :position, :featured)
    end
  end
end
