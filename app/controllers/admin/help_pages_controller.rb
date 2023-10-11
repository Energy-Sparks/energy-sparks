module Admin
  class HelpPagesController < AdminController
    include LocaleHelper
    load_and_authorize_resource

    def index
      @help_pages = HelpPage.all.by_title
    end

    def new; end

    def create
      if @help_page.save
        redirect_to admin_help_pages_path, notice: 'Help page has been created'
      else
        render :new
      end
    end

    def edit; end

    def update
      if @help_page.update(help_page_params)
        redirect_to admin_help_pages_path, notice: 'Help page has been updated'
      else
        render :edit
      end
    end

    def publish
      @help_page.update!(published: true)
      redirect_to admin_help_pages_path, notice: 'Help page published'
    end

    def hide
      @help_page.update!(published: false)
      redirect_to admin_help_pages_path, notice: 'Help page hidden'
    end

    private

    def help_page_params
      translated_params = t_params(HelpPage.mobility_attributes)
      params.require(:help_page).permit(translated_params, :title, :description, :published, :feature)
    end
  end
end
