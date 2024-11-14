class HelpPagesController < ApplicationController
  load_resource :help_page
  skip_before_action :authenticate_user!

  def show
    if @help_page.published?
      render :show
    elsif current_user && current_user.admin?
      render :show
    else
      route_not_found
    end
  end
end
