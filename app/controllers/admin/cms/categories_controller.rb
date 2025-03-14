module Admin
  module Cms
    class CategoriesController < AdminController
      include LocaleHelper
      load_and_authorize_resource :category, class: 'Cms::Category'

      def index
        @categories = ::Cms::Category.all.by_title
      end

      def new
      end

      def create
        @category = ::Cms::Category.build(category_params.merge(created_by: current_user))
        if @category.save
          redirect_to admin_cms_categories_path, notice: 'Category has been created'
        else
          render :new
        end
      end

      def edit
      end

      def update
        if @category.update(category_params.merge(updated_by: current_user))
          redirect_to admin_cms_categories_path, notice: 'Category has been updated'
        else
          render :edit
        end
      end

      def publish
        @category.update!(published: true, updated_by: current_user)
        redirect_back fallback_location: admin_cms_categories_path, notice: 'Content published'
      end

      def hide
        @category.update!(published: false, updated_by: current_user)
        redirect_back fallback_location: admin_cms_categories_path, notice: 'Content hidden'
      end

      private

      def category_params
        translated_params = t_params(::Cms::Category.mobility_attributes)
        params.require(:category).permit(translated_params, :title, :description, :published, :icon)
      end
    end
  end
end
