class MailchimpSubscriber
  class Error < StandardError; end

  def initialize(mailchimp_api)
    @mailchimp_api = mailchimp_api
  end

  def subscribe(school, user)
    list = @mailchimp_api.list_with_interests
    config = mailchimp_signup_params(school, user, list)
    if list && config.valid?
      begin
        @mailchimp_api.subscribe(list.id, config)
      rescue MailchimpApi::Error => e
        raise Error.new(e)
      end
    end
  end

  def mailchimp_signup_params(school, user, list)
    MailchimpSignupParams.new(
      email_address: user.email,
      tags: MailchimpTags.new(school).tags,
      interests: map_interests(school, list),
      merge_fields: {
        'FULLNAME' => user.name,
        'SCHOOL' => school.name,
      }
    )
  end

  def map_interests(school, list)
    if school.school_group
      list.categories.each do |category|
        category.interests.each do |interest|
          if interest.name == school.school_group.name
            return { interest.id => true }
          end
        end
      end
    end
    {}
  end
end
