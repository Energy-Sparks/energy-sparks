# frozen_string_literal: true

module Cms
  class PagesController < ApplicationController
    skip_before_action :authenticate_user!
    load_resource :page

    def show
      @categories = Cms::Category.all.published.by_title
      render :show, layout: 'dashboards'
    end
  end
end
