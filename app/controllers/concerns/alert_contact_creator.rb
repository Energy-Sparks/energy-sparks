module AlertContactCreator
  extend ActiveSupport::Concern

  private

  def existing_alert_contact?(school, user)
    user.contacts.where(school: school).any?
  end

  def update_alert_contact(school, user)
    if auto_create_alert_contact?
      create_or_update_alert_contact(school, user)
    elsif existing_alert_contact?(school, user)
      delete_contact(school, user)
    end
  end

  def create_or_update_alert_contact(school, user)
    if existing_alert_contact?(school, user)
      contact = user.contacts.where(school: school).first
      contact.update!(
        email_address: user.email,
        name: user.name,
        staff_role_id: user.staff_role_id
      )
    else
      Contact.create!(email_address: user.email, name: user.name, school: school, user: user, staff_role_id: user.staff_role_id)
    end
  end

  def create_alert_contact(school, user)
    Contact.create!(email_address: user.email, name: user.name, school: school, user: user, staff_role_id: user.staff_role_id)
  end

  def delete_contact(_school, user)
    user.contacts.where(school: @school).delete_all
  end

  def auto_create_alert_contact?
    params[:contact] && params[:contact][:auto_create_alert_contact] && ActiveModel::Type::Boolean.new.cast(params[:contact][:auto_create_alert_contact])
  end
end
