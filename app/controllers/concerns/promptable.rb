module Promptable
  extend ActiveSupport::Concern

  def show_standard_prompts?(resource)
    if user_signed_in? && current_user.admin?
      true
    elsif user_signed_in_and_linked_to_school? && can?(:show_management_dash, resource)
      true
    else
      false
    end
  end

  def user_signed_in_and_linked_to_school?
    user_signed_in? && (current_user.school_id == @school.id)
  end
end
