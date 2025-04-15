# frozen_string_literal: true

module Cms
  class PagesController < ApplicationController
    include Pagy::Backend
    include ContentManagement

    skip_before_action :authenticate_user!
    load_and_authorize_resource :page

    before_action :redirect_unless_feature_enabled?
    before_action :load_categories

    layout 'dashboards'

    def show
      render :show, layout: 'dashboards'
    end

    def search
      # TODO visibility?
      @pagy, @results = pagy(Cms::Section.search(query: params[:query], locale: I18n.locale))
    end
  end
end
