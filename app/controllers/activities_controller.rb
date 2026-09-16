# frozen_string_literal: true

class ActivitiesController < ApplicationController
  before_action :enable_bootstrap5
  before_action :enable_feature

  # load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:index]

  def index; end

  private

  def enable_feature
    redirect_to root_path unless Flipper.enabled?(:activities_index, current_user)
    # Implementation for enabling feature
  end
end
