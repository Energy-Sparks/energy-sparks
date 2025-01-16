class MailchimpSignupsController < ApplicationController
  skip_before_action :authenticate_user!

  # FIXME create contact?
  def new
    @list = audience_manager.list
    @email_types = list_of_email_types
    @contact = Mailchimp::Contact.new(params[:email_address])
  rescue => e
    flash[:error] = 'Mailchimp API is not configured'
    Rails.logger.error "Mailchimp API is not configured - #{e.message}"
    Rollbar.error(e)
  end

  # FIXME errors?
  def index
  end

  # FIXME passing interests
  # FIXME further refactoring?
  def create
    #    if params[:email_address]
    #      contact = Mailchimp::Contact.from_params(user, interests: default_interests)
    #      resp = subscribe_contact(contact)
    #      if resp
    #        redirect_to mailchimp_signups_path and return
    #      end
    #    elsif current_user
    #      contact = Mailchimp::Contact.from_user(user, interests: default_interests)
    #      subscribe_contact(contact)
    #      redirect_to mailchimp_signups_path and return
    #    else
    #      redirect_to new_mailchimp_signup_path and return
    #    end
    #    render :new
  end

  private

  def audience_manager
    @audience_manager ||= Mailchimp::AudienceManager.new
  end

  # FIXME
  # Capturing user preferences for types of email in a group called "Email Preferences"
  def list_of_email_types
    category = audience_manager.categories.first {|c| c.title == 'Email Preferences' }
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
        resp = audience_manager.new.subscribe_or_update_contact(contact)
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

  def mailchimp_api
    @mailchimp_api ||= MailchimpApi.new
  end

  # TODO create instance of new model
  # TODO change form to use simple fields and a contact
  def mailchimp_signup_params(params)
    MailchimpSignupParams.new(
      email_address: params[:email_address],
      tags: params[:tags],
      interests: params[:interests],
      merge_fields: params[:merge_fields]
    )
  end
end
