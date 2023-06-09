module Promptable
  extend ActiveSupport::Concern

  def show_standard_prompts?(resource)
    if user_signed_in? && current_user.admin?
      true
    elsif can?(:show_management_dash, resource)
      true
    else
      false
    end
  end
end
