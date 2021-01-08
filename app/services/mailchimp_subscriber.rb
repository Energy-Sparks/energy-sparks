class MailchimpSubscriber
  class Error < StandardError; end

  def initialize(mailchimp_api)
    @mailchimp_api = mailchimp_api
  end

  def subscribe(school, user)
    list = @mailchimp_api.list_with_interests
    config = mailchimp_signup_params(school, user, list)
    if list && config.valid?
      @mailchimp_api.subscribe(list.id, config)
    else
      raise Error.new('Mailchimp subscribe failed')
    end
  rescue MailchimpApi::Error => e
    raise MailchimpSubscriber::Error.new(e)
  end

  def mailchimp_signup_params(school, user, list)
    MailchimpSignupParams.new(
      email_address: user.email,
      tags: MailchimpTags.new(school).tags,
      interests: find_interests(school, list),
      merge_fields: {
        'FULLNAME' => user.name,
        'SCHOOL' => school.name,
      }
    )
  end

  def find_interests(school, list)
    ret = {}
    if school.school_group
      list.categories.each do |category|
        category.interests.each do |interest|
          if interest.name == school.school_group.name
            ret[interest.id] = interest.id
          end
        end
      end
    end
    ret
  end
end
