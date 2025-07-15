class NewslettersController < ApplicationController
  skip_before_action :authenticate_user!

  layout :choose_layout

  def index
    @newsletters = Newsletter.published.order(published_on: :desc)
  end

  private

  def choose_layout
    if Flipper.enabled?(:new_newsletters_page, current_user)
      'home'
    else
      'application'
    end
  end
end
