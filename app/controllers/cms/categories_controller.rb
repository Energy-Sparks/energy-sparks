# frozen_string_literal: true

module Cms
  class CategoriesController < ApplicationController
    include ContentManagement

    skip_before_action :authenticate_user!
    load_and_authorize_resource :category, except: [:index]

    before_action :redirect_unless_feature_enabled?

    before_action :load_categories
    before_action :set_breadcrumbs

    layout 'dashboards'

    def index
      render :index
    end

    def show
      render :show
    end

    private

    def set_breadcrumbs
      if @category
        @breadcrumbs = [
          { name: I18n.t('categories.nav.title'), href: support_path },
          { name: @category.title, href: category_path(@category) }
        ]
      end
    end
  end
end
