module NewsletterSubscriber
  extend ActiveSupport::Concern

  private

  def set_email_types
    @email_types = list_of_email_types
  end

  def default_interests(user = nil)
    Mailchimp::Contact.default_interests(@email_types, user)
  end

  def create_contact_from_user(user, sign_up_params)
    Mailchimp::Contact.from_user(user, interests: sign_up_params[:interests].transform_values {|v| v == 'true' })
  end

  def subscribe_contact(contact, user, show_errors: true)
    resp = nil
    if contact.valid?
      begin
        # as user has explicitly signed up, set their status to be subscribed if they're an existing contact in Mailchimp
        resp = audience_manager.subscribe_or_update_contact(contact, status: 'subscribed')
        user.update(mailchimp_status: 'subscribed', mailchimp_updated_at: Time.zone.now) if user
      rescue => e
        Rails.logger.error(e)
        Rollbar.error(e)
        flash[:error] = I18n.t('mailchimp_signups.index.unable_to_process_subscription') if show_errors
      end
    elsif show_errors
      flash[:error] = contact.errors.full_messages.join(', ')
    end
    resp
  end

  def audience_manager
    @audience_manager ||= Mailchimp::AudienceManager.new
  end

  def list_of_email_types
    category = audience_manager.categories.detect {|c| c.title == 'Interests' }
    return [] unless category
    return audience_manager.interests(category.id)
  rescue => e
    Rails.logger.error(e)
    Rollbar.error(e)
    []
  end
end
