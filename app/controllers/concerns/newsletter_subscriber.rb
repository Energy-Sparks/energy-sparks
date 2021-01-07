module NewsletterSubscriber
  extend ActiveSupport::Concern

  private

  def subscribe_newsletter(school, user)
    @list = mailchimp_api.list_with_interests
    @config = mailchimp_signup_params(school, user)
    if @config.valid?
      begin
        mailchimp_api.subscribe(@list.id, @config)
      rescue MailchimpApi::Error => e
        flash[:error] = e.message
      end
    end
  end

  def auto_subscribe_newsletter?
    params[:user] && params[:user].key?(:auto_subscribe_newsletter)
  end

  def mailchimp_api
    @mailchimp_api ||= MailchimpApi.new
  end

  def mailchimp_signup_params(school, user)
    MailchimpSignupParams.new(
      email_address: user.email,
      tags: MailchimpTags.new(school).tags,
      interests: {},
      merge_fields: {
        'FULLNAME' => user.name,
        'SCHOOL' => school.name,
      }
    )
  end
end
