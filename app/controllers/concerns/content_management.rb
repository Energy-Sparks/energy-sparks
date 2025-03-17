# frozen_string_literal: true

module ContentManagement
  extend ActiveSupport::Concern

  private

  def load_categories
    @categories = Cms::Category.all.published.by_title
  end

  def redirect_unless_feature_enabled?
    redirect_to root_path, notice: 'You are not authorized' unless Flipper.enabled?(:support_pages, current_user)
  end
end
