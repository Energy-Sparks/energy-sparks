# frozen_string_literal: true

module Cms
  class CategoriesController < ApplicationController
    include ContentManagement

    skip_before_action :authenticate_user!
    load_and_authorize_resource :category, except: [:index]

    before_action :redirect_unless_feature_enabled?

    before_action :load_categories

    layout 'dashboards'

    def index
      render :index
    end

    def show
      render :show
    end
  end
end
