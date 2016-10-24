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
end
