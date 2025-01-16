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
      interests['interests'].map { |interest| OpenStruct.new(interest) }.sort_by(&:name)
    end

    # Subscribe a Marketing::MailchimpContact to our list
    # Raises exception if a subscriber
    def subscribe_contact(mailchimp_contact)
      resp = @client.lists.add_list_member(list.id, mailchimp_contact.to_mailchimp_hash, subscribe_opts)
      OpenStruct.new(resp)
    end

    def subscribe_or_update_contact(mailchimp_contact, status_if_new: 'subscribed')
      hash = mailchimp_contact.to_mailchimp_hash
      hash['status_if_new'] = status_if_new
      resp = @client.lists.set_list_member(list.id, mailchimp_contact.email_address, hash, subscribe_opts)
      OpenStruct.new(resp)
    end

    def archive_contact(email_address)
      resp = @client.lists.delete_list_member(list.id, Digest::MD5.hexdigest(email_address.downcase))
      OpenStruct.new(resp)
    end

    def update_contact(mailchimp_contact)
      resp = @client.lists.set_list_member(list.id, Digest::MD5.hexdigest(mailchimp_contact.email_address.downcase), mailchimp_contact.to_mailchimp_hash, subscribe_opts)
      OpenStruct.new(resp)
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

    def subscribe_opts
      {
        skip_merge_validation: true
      }
    end
  end
end
