# frozen_string_literal: true

module Cms
  class CategoriesController < ApplicationController
    skip_before_action :authenticate_user!
    load_resource :category

    def index
      @categories = Cms::Category.all.published.by_title
      render :index, layout: 'dashboards'
    end

    def show
      @categories = Cms::Category.all.published.by_title
      render :show, layout: 'dashboards'
    end
  end
end
