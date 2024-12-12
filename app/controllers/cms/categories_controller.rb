# frozen_string_literal: true

module Cms
  class CategoriesController < ApplicationController
    skip_before_action :authenticate_user!

    def index
    end

    def show
    end
  end
end
