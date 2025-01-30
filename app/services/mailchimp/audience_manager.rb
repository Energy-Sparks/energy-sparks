module Mailchimp
  class AudienceManager
    def initialize(client = Rails.configuration.mailchimp_client)
      @client = client
    end

    # Fetch the description of our Mailchimp mailing list
    def list
      @list ||= get_list
    end

    def categories
      categories = @client.lists.get_list_interest_categories(list.id, count: 100)
      categories['categories'].map { |category| OpenStruct.new(category) }
    end

    def interests(category_id)
      interests = @client.lists.list_interest_category_interests(list.id, category_id, count: 100)
      interests['interests'].map { |interest| create_interest(interest) }.sort_by(&:name)
    end

    def subscribe_or_update_contact(mailchimp_contact, status_if_new: 'subscribed')
      hash = mailchimp_contact.to_mailchimp_hash
      hash['status_if_new'] = status_if_new
      resp = @client.lists.set_list_member(list.id, mailchimp_contact.email_address, hash, subscribe_opts)
      OpenStruct.new(resp)
    end

    def get_contact(email_address)
      resp = @client.lists.get_list_member(list.id, email_address.downcase)
      OpenStruct.new(resp)
    rescue
      nil
    end

    private

    def get_list
      lists = @client.lists.get_all_lists
      if lists.empty?
        nil
      else
        OpenStruct.new(lists['lists'].first)
      end
    end

    def create_interest(interest)
      interest = OpenStruct.new(interest)
      key = interest.name.parameterize.underscore
      interest.i18n_name = I18n.t("mailchimp.audience_manager.interests.#{key}", default: interest.name)
      interest
    end

    def subscribe_opts
      {
        skip_merge_validation: true
      }
    end
  end
end
