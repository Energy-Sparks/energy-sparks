class NewslettersController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    @newsletters = Newsletter.order(published_on: :desc)
  end
end
