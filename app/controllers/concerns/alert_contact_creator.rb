module AlertContactCreator
  extend ActiveSupport::Concern

  private

  def create_alert_contact(school, user)
    Contact.create!(email_address: user.email, name: user.name, school: school, user: user, staff_role_id: user.staff_role_id)
  end

  def auto_create_alert_contact?
    params[:user] && params[:user].key?(:auto_create_alert_contact)
  end
end
