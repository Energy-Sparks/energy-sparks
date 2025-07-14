module Admin
  class NewslettersController < AdminController
    include ImageResizer

    load_and_authorize_resource
    before_action only: [:create, :update] do
      resize_image(newsletter_params[:image])
    end

    # GET /newsletters
    def index
      @newsletters = Newsletter.all.order(:published_on)
    end

    # GET /newsletters/1
    def show
    end

    # GET /newsletters/new
    def new
    end

    # GET /newsletters/1/edit
    def edit
    end

    # POST /newsletters
    def create
      @newsletter = Newsletter.new(newsletter_params.merge(created_by: current_user))
      if @newsletter.save
        redirect_to admin_newsletters_path, notice: 'Newsletter was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /newsletters/1
    def update
      if @newsletter.update(newsletter_params.merge(updated_by: current_user))
        redirect_to admin_newsletters_path, notice: 'Newsletter was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /newsletters/1
    def destroy
      @newsletter.destroy
      redirect_to admin_newsletters_path, notice: 'Newsletter was successfully destroyed.'
    end

    private

    def newsletter_params
      params.require(:newsletter).permit(:title, :url, :published_on, :image)
    end
  end
end
