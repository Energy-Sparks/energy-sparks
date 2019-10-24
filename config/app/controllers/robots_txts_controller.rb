class RobotsTxtsController < ApplicationController
  def show
    if allow_crawling?
      render :allow, layout: false, content_type: "text/plain"
    else
      render :disallow_all, layout: false, content_type: "text/plain"
    end
  end

  private

  def allow_crawling?
    ENV.key?("ALLOW_CRAWLING")
  end
end
