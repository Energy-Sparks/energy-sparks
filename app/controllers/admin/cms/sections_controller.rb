module Admin
  module Cms
    class SectionsController < AdminController
      include LocaleHelper
      load_and_authorize_resource :section, class: 'Cms::Section'

      def index
        @sections = ::Cms::Section.all.by_category_and_page
      end

      def new
      end

      def create
        @section = ::Cms::Section.build(section_params.merge(created_by: current_user))
        if @section.save
          redirect_to admin_cms_sections_path, notice: 'Section has been created'
        else
          render :new
        end
      end

      def edit
      end

      def update
        if @section.update(section_params.merge(updated_by: current_user))
          redirect_to admin_cms_sections_path, notice: 'Section has been updated'
        else
          render :edit
        end
      end

      def publish
        @section.update!(published: true, updated_by: current_user)
        redirect_back fallback_location: admin_cms_sections_path, notice: 'Content published'
      end

      def hide
        @section.update!(published: false, updated_by: current_user)
        redirect_back fallback_location: admin_cms_sections_path, notice: 'Content hidden'
      end

      private

      def section_params
        translated_params = t_params(::Cms::Section.mobility_attributes)
        params.require(:section).permit(translated_params, :title, :body, :published, :page_id)
      end
    end
  end
end
