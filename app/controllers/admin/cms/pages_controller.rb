module Admin
  module Cms
    class PagesController < AdminController
      include LocaleHelper
      load_and_authorize_resource :page, class: 'Cms::Page'

      def index
        @pages = ::Cms::Page.all.by_category_and_title
      end

      def new
      end

      def create
        @page = ::Cms::Page.build(page_params.merge(created_by: current_user))
        if @page.save
          redirect_to category_page_path(@page.category, @page), notice: 'Page has been created'
        else
          render :new
        end
      end

      def edit
      end

      def update
        # Remove deleted associations
        if params[:page][:sections_attributes]
          params[:page][:sections_attributes].each do |id, section_params|
            section_id = section_params[:id]
            if section_params[:_delete] == '1'
              @page.sections.where(id: section_id).update(page_id: nil, position: nil, published: false)
              params[:page][:sections_attributes].delete(id)
            end
          end
        end
        if @page.update(page_params.merge(updated_by: current_user))
          redirect_to category_page_path(@page.category, @page), notice: 'Page has been updated'
        else
          render :edit
        end
      end

      def publish
        @page.update!(published: true, updated_by: current_user)
        redirect_back fallback_location: category_page_path(@page.category, @page), notice: 'Content published'
      end

      def hide
        @page.update!(published: false, updated_by: current_user)
        redirect_back fallback_location: category_page_path(@page.category, @page), notice: 'Content hidden'
      end

      private

      def page_params
        translated_params = t_params(::Cms::Page.mobility_attributes)
        params.require(:page).permit(translated_params, :title, :description, :published,
          :category_id, :audience, sections_attributes: sections_attributes)
      end

      def sections_attributes
        [:id, :position, :_delete]
      end
    end
  end
end
