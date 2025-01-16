class MailchimpSignupsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @contact = Mailchimp::Contact.new(params[:email_address])
  rescue => e
    flash[:error] = 'Mailchimp API is not configured'
    Rails.logger.error "Mailchimp API is not configured - #{e.message}"
    Rollbar.error(e)
  end

  def index
  end

  def create
    @contact = Mailchimp::Contact.from_params(sign_up_params)
    if params[:email_address]
      resp = subscribe_contact(@contact)
      if resp
        redirect_to mailchimp_signups_path and return
      end
    end
    @list = audience_manager.list
    @email_types = list_of_email_types
    render :new
  end

  private

  def audience_manager
    @audience_manager ||= Mailchimp::AudienceManager.new
  end

  # FIXME
  # Capturing user preferences for types of email in a group called "Email Preferences"
  def list_of_email_types
    category = audience_manager.categories.detect {|c| c.title == 'Email Preferences' }
    return [] unless category
    return audience_manager.interests(category.id)
  rescue => e
    Rails.logger.error(e)
    Rollbar.error(e)
    []
  end

  def subscribe_contact(contact)
    resp = nil
    if contact.valid?
      begin
        resp = audience_manager.subscribe_or_update_contact(contact)
      rescue => e
        Rails.logger.error(e)
        Rollbar.error(e)
        flash[:error] = 'Unable to process Mailchimp newsletter subscription'
      end
    else
      flash[:error] = contact.errors.full_messages.join(', ')
    end
    resp
  end

  def sign_up_params
    params.permit(:email_address, :name, :school, interests: {})
  end
end
