module AlertContactCreator
  extend ActiveSupport::Concern

  private

  def find_contact(school, user)
    Schools::ContactFinder.new(school).contact_for(user)
  end

  def existing_alert_contact?(school, user)
    find_contact(school, user).present?
  end

  def update_alert_contact(school, user)
    if subscribe_to_alerts?
      create_or_update_alert_contact(school, user)
    elsif existing_alert_contact?(school, user)
      delete_contact(school, user)
    end
  end

  def create_or_update_alert_contact(school, user)
    if (contact = find_contact(school, user))
      contact.update!(
        user: user,
        email_address: user.email,
        name: user.name,
        staff_role_id: user.staff_role_id
      )
    else
      create_alert_contact(school, user)
    end
  end

  def create_alert_contact(school, user)
    Contact.create!(email_address: user.email, name: user.name, school: school, user: user, staff_role_id: user.staff_role_id)
  end

  def delete_contact(school, user)
    if (contact = find_contact(school, user))
      contact.delete
    end
  end

  def subscribe_to_alerts?
    params[:contact] && params[:contact][:auto_create_alert_contact] && ActiveModel::Type::Boolean.new.cast(params[:contact][:auto_create_alert_contact])
  end
end
