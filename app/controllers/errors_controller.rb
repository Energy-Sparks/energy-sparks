class ErrorsController < ApplicationController
  include ApplicationHelper
  skip_before_action :authenticate_user!

  CODES = %w[404 500 422].freeze

  def show
    code = CODES.include?(params[:code]) ? params[:code] : 500
    respond_to do |format|
      format.html { render status: code }
      format.any { head code }
    end
  end
end
