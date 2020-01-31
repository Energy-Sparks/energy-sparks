module UserTypeSpecific
  extend ActiveSupport::Concern

  private

  def user_type_hash
    if current_user
      { user_role: current_user.role.to_sym, staff_role: current_user.staff_role_as_symbol }
    else
      { user_role: :guest, staff_role: nil }
    end
  end
end
