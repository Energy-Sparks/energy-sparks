# from the rails 7 health controller
class HealthController < ActionController::Base # rubocop:disable Rails/ApplicationController
  rescue_from(Exception) { render_down }

  def show
    render_up
  end

  private

  def render_up
    render html: html_status(color: "green")
  end

  def render_down
    render html: html_status(color: "red"), status: :internal_server_error
  end

  def html_status(color:)
    %(<!DOCTYPE html><html><body style="background-color: #{color}"></body></html>).html_safe
  end
end
