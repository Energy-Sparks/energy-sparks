# frozen_string_literal: true

module ContentManagement
  extend ActiveSupport::Concern

  private

  def load_categories
    scope = if current_user_admin?
              Cms::Category.all
            else
              Cms::Category.all.published
            end
    @categories = scope.by_title
  end

  def redirect_unless_feature_enabled?
    redirect_to root_path, notice: 'You are not authorized' unless Flipper.enabled?(:support_pages, current_user)
  end
end
