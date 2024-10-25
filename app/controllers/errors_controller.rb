class ErrorsController < ApplicationController
  include ApplicationHelper
  skip_before_action :authenticate_user!

  def page_not_found
  end

  def internal_server_error
  end

  def unprocessable_entity
  end
end
