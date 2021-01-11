class MailchimpSubscriber
  class Error < StandardError; end

  def initialize(mailchimp_api)
    @mailchimp_api = mailchimp_api
  end

  def subscribe(school, user)
    list = @mailchimp_api.list_with_interests
    if list
      config = mailchimp_signup_params(school, user, list)
      if config.valid?
        @mailchimp_api.subscribe(list.id, config)
      else
        raise MailchimpSubscriber::Error.new('Invalid newsletter subscription parameters')
      end
    else
      raise MailchimpSubscriber::Error.new('Mailchimp API failed')
    end
  rescue MailchimpApi::Error => e
    raise MailchimpSubscriber::Error.new(e)
  end

  def mailchimp_signup_params(school, user, list)
    MailchimpSignupParams.new(
      email_address: user.email,
      tags: MailchimpTags.new(school).tags,
      interests: find_interests(school, user, list),
      merge_fields: {
        'FULLNAME' => user.name,
        'SCHOOL' => school.name,
      }
    )
  end

  def find_interests(school, user, list)
    ret = {}
    items = []
    items << school.school_group.name if school.school_group
    items << user.staff_role.title if user.staff_role
    unless items.empty?
      list.categories.each do |category|
        category.interests.each do |interest|
          if items.include?(interest.name)
            ret[interest.id] = interest.id
          end
        end
      end
    end
    ret
  end
end
