module Mailchimp
  class AudienceManager
    def initialize(client = Rails.configuration.mailchimp_client)
      @client = client
    end

    # The Mailchimp documentation and CSV exports use different status names than
    # the API. Specifically "nonsubscribed" in the documentation is returned as "transactional"
    # in the API responses. Ensure we're using codes that align with our enum.
    #
    # Preferring the documented versions as they will match internal user expectations
    def self.status(mailchimp_status)
      mailchimp_status == 'transactional' ? :nonsubscribed : mailchimp_status.to_sym
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
      interests['interests'].map { |interest| create_interest(interest) }
    end

    # Calls a Mailchimp API in a way that will add new contacts to the list if they're not already
    # members or updates an existing contact.
    #
    # Care need to be taken with the status flags here, as if a user is already a member then we don't
    # necessarily want to override their current status (e.g. unsubscribed or archived) unless a user
    # has requested it.
    #
    # Status defaults to `nil` here to enforce a default that respects changes within Mailchimp.
    def subscribe_or_update_contact(mailchimp_contact, status_if_new: 'subscribed', status: nil)
      hash = mailchimp_contact.to_mailchimp_hash
      hash['status_if_new'] = status_if_new
      hash['status'] = status if status
      resp = @client.lists.set_list_member(list.id, mailchimp_key(mailchimp_contact), hash, subscribe_opts)
      OpenStruct.new(resp)
    end

    def remove_tags_from_contact(email_address, tags_to_remove)
      tags = tags_to_remove.map { |t| { 'name' => t, 'status' => 'inactive' } }
      @client.lists.update_list_member_tags(list.id,
                                            Digest::MD5.hexdigest(email_address.downcase),
                                            { 'tags': tags }
                                          )
    end

    def update_contact(mailchimp_contact, original_email = nil)
      resp = @client.lists.set_list_member(list.id,
                                           mailchimp_key(mailchimp_contact, original_email),
                                           mailchimp_contact.to_mailchimp_hash,
                                           subscribe_opts)
      OpenStruct.new(resp)
    end

    def get_list_member(email_address)
      resp = @client.lists.get_list_member(list.id, email_address.downcase)
      OpenStruct.new(resp)
    rescue
      nil
    end

    def list_members(offset: 0, page_size: 1000)
      resp = @client.lists.get_list_members_info(list.id, offset: offset, count: page_size)
      OpenStruct.new(resp)
    end

    # Page through entire list of Mailchimp users. Will return the full list, or yield
    # each member if a block is given
    def process_list_members(page_size: 1000)
      offset = 0
      members = []
      resp = list_members(offset:, page_size:)
      total_items = resp.total_items
      members.concat(resp.members.map {|m| OpenStruct.new(m) })
      if block_given?
        resp.members.each do |member|
          yield OpenStruct.new(member)
        end
      end
      while offset + page_size < total_items
        offset += page_size
        resp = list_members(offset:, page_size:)
        members.concat(resp.members.map {|m| OpenStruct.new(m) })
        if block_given?
          resp.members.each do |member|
            yield OpenStruct.new(member)
          end
        end
      end
      members
    end

    private

    def mailchimp_key(contact, old_email_address = nil)
      if old_email_address
        Digest::MD5.hexdigest(old_email_address.downcase)
      else
        Digest::MD5.hexdigest(contact.email_address.downcase)
      end
    end

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
      interest.i18n_name = I18n.t("mailchimp.audience_manager.interests.#{key}.name", default: interest.name)
      interest.i18n_description = I18n.t("mailchimp.audience_manager.interests.#{key}.description_html", default: '')
      interest
    end

    def subscribe_opts
      {
        skip_merge_validation: true
      }
    end
  end
end
