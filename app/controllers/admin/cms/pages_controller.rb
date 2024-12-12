module Admin
  module Cms
    class PagesController < AdminController
      include LocaleHelper
      load_and_authorize_resource :page, class: 'Cms::Page'

      def index
        @pages = ::Cms::Page.all.by_title
      end

      def new
      end

      def create
        if @page.save
          redirect_to admin_cms_pages_path, notice: 'Page has been created'
        else
          render :new
        end
      end

      def edit
      end

      def update
        if @page.update(page_params)
          redirect_to admin_cms_pages_path, notice: 'Page has been updated'
        else
          render :edit
        end
      end

      def publish
        @page.update!(published: true)
        redirect_to admin_cms_pages_path, notice: 'Page published'
      end

      def hide
        @page.update!(published: false)
        redirect_to admin_cms_pages_path, notice: 'Page hidden'
      end

      private

      def page_params
        translated_params = t_params(::Cms::Page.mobility_attributes)
        params.require(:page).permit(translated_params, :title, :description, :published, :category_id)
      end
    end
  end
end
