class MailchimpSubscriber
  class Error < StandardError; end

  def initialize(mailchimp_api)
    @mailchimp_api = mailchimp_api
  end

  def subscribe(user)
    list = @mailchimp_api.list_with_interests
    if list
      config = mailchimp_signup_params(user, list)
      if config.valid?
        @mailchimp_api.subscribe(list.id, config)
      else
        raise MailchimpSubscriber::Error, 'Invalid newsletter subscription parameters'
      end
    else
      raise MailchimpSubscriber::Error, 'Mailchimp API failed'
    end
  rescue MailchimpApi::Error => e
    raise MailchimpSubscriber::Error, e
  end

  def mailchimp_signup_params(user, list)
    params = MailchimpSignupParams.new(email_address: user.email)
    params.interests = find_interests(user, list)
    params.merge_fields = merge_fields(user)
    params.tags = MailchimpTags.new(user.school).tags if user.school
    params
  end

  def merge_fields(user)
    fields = {}
    fields['FULLNAME'] = user.name if user
    fields['SCHOOL'] = user.school.name if user.school
    fields
  end

  def find_interests(user, list)
    ret = {}
    items = []
    items << user.school_group_name if user.school_group_name
    items << user.staff_role.title if user.staff_role
    unless items.empty?
      list.categories.each do |category|
        category.interests.each do |interest|
          ret[interest.id] = interest.id if items.include?(interest.name)
        end
      end
    end
    ret
  end
end
