class RobotsTxtsController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    if allow_all_crawling?
      render :allow, layout: false, content_type: "text/plain"
    else
      render :disallow_all, layout: false, content_type: "text/plain"
    end
  end

  private

  def allow_all_crawling?
    ENV["ALLOW_CRAWLING"].present?
  end
end
