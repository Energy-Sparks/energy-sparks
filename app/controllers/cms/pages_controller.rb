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

    layout 'dashboards'

    def show
      render :show, layout: 'dashboards'
    end

    def search
      @pagy, @results = pagy(Cms::Section.search(query: params[:query],
                                                 locale: I18n.locale,
                                                 show_all: current_user_admin?))
    end
  end
end
