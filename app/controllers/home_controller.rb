class HomeController < ApplicationController
  # **** ALL ACTIONS IN THIS CONTROLLER ARE PUBLIC! ****
  skip_before_action :authenticate_user!

  def index
  end

  def about
  end

  def contact
  end

  def enrol
  end

  def help
    # assign page, remove any non-alphanumeric characters, allow underscores
    @help_page = params[:help_page].tr('^A-Za-z0-9_', '') if params[:help_page]
  end
end
