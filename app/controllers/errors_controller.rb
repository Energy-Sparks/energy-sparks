class ErrorsController < ApplicationController
  include ApplicationHelper
  skip_before_action :authenticate_user!

  def not_found
    render 'error', status: :not_found
  end

  def internal_server_error
    render 'error', status: :internal_server_error
  end

  def unprocessable_entity
    render 'error', status: :unprocessable_entity
  end
end
