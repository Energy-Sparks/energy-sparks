class HomeController < ApplicationController
  # **** ALL ACTIONS IN THIS CONTROLLER ARE PUBLIC! ****
  skip_before_action :authenticate_user!

  def index
  end
end
