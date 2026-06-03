# frozen_string_literal: true

module Cms
  class PagesController < ApplicationController
    include Pagy::Backend
    include ContentManagement

    skip_before_action :authenticate_user!
    load_and_authorize_resource :page, only: [:show]

    before_action :redirect_unless_feature_enabled?
    before_action :load_categories
    before_action :load_sections, only: [:show]
    before_action :set_breadcrumbs

    layout 'dashboards'

    def show
      render :show, layout: 'dashboards'
    end

    def search
      @pagy, @results = pagy(Cms::Section.search(query: params[:query],
                                                 locale: I18n.locale,
                                                 show_all: current_user_admin?))
    end

    private

    def load_sections
      scope = if current_user_admin?
                @page.sections
              else
                @page.sections.published
              end
      @sections = scope.positioned
    end

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('categories.nav.title'), href: support_path }]
      if @page
        @breadcrumbs = @breadcrumbs + [
          { name: @page.category.title, href: category_path(@page.category) },
          { name: @page.title, href: category_page_path(@page.category, @page) }
        ]
      else
        @breadcrumbs << { name: I18n.t('pages.search.button'), href: search_path }
      end
    end
  end
end
