module Adminable
  extend ActiveSupport::Concern

  # private

  def admin_authorized?
    unless can?(:manage, :admin_functions)
      flash[:error] = "You are not authorized to view that page."
      redirect_to root_path
    end
  end
end
