module NewsletterSubscriber
  extend ActiveSupport::Concern

  private

  def create_contact_from_user(user, sign_up_params)
    Mailchimp::Contact.from_user(user, interests: sign_up_params[:interests].transform_values {|v| v == 'true' })
  end

  def subscribe_contact(contact, show_errors: true)
    resp = nil
    if contact.valid?
      begin
        resp = audience_manager.subscribe_or_update_contact(contact)
      rescue => e
        Rails.logger.error(e)
        Rollbar.error(e)
        flash[:error] = 'Unable to process Mailchimp newsletter subscription' if show_errors
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
