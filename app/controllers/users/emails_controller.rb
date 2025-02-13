module Users
  class EmailsController < ApplicationController
    load_resource :user

    def index
      render :index, layout: 'dashboards'
    end

    def update
    end
  end
end
