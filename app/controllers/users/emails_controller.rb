module Users
  class EmailsController < ApplicationController
    include NewsletterSubscriber

    load_resource :user
    before_action :set_email_types

    def index
      audience_manager.list # load to ensure config is set
      @interests = user_interests(@user)
      render :index, layout: 'dashboards'
    rescue => e
      Rails.logger.error "Mailchimp API is not configured - #{e.message}"
      Rollbar.error(e)
      raise e
    end

    def create
      contact = create_contact_from_user(@user, params.permit(interests: {}))
      resp = subscribe_contact(contact, @user, show_errors: true)
      if resp
        redirect_to user_path(@user), notice: t('users.emails.update.updated')
      else
        render :index, layout: 'dashboards'
      end
    end
  end
end
