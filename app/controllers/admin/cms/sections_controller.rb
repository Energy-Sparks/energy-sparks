module Admin
  module Cms
    class SectionsController < AdminController
      include LocaleHelper
      load_and_authorize_resource :section, class: 'Cms::Section'

      def index
        @sections = ::Cms::Section.all.by_title
      end

      def new
      end

      def create
        if @section.save
          redirect_to admin_cms_sections_path, notice: 'Section has been created'
        else
          render :new
        end
      end

      def edit
      end

      def update
        if @section.update(section_params)
          redirect_to admin_cms_sections_path, notice: 'Section has been updated'
        else
          render :edit
        end
      end

      def publish
        @section.update!(published: true)
        redirect_to admin_cms_sections_path, notice: 'Section published'
      end

      def hide
        @section.update!(published: false)
        redirect_to admin_cms_sections_path, notice: 'Section hidden'
      end

      private

      def section_params
        translated_params = t_params(::Cms::Section.mobility_attributes)
        params.require(:section).permit(translated_params, :title, :body, :published, :page_id, :position)
      end
    end
  end
end
