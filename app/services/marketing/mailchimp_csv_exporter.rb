module Marketing
  class MailchimpCsvExporter
    # hash of four categories, each containing a list of MailchimpContact
    attr_reader :updated_audience, :new_nonsubscribed

    # List of hashed fields from Mailchimp
    def initialize(subscribed:, nonsubscribed:, cleaned:, unsubscribed:)
      @audience = {}
      @updated_audience = { subscribed: [], nonsubscribed: [], cleaned: [], unsubscribed: [] }
      @new_nonsubscribed = []
      populate_audience(subscribed: subscribed, nonsubscribed: nonsubscribed, cleaned: cleaned, unsubscribed: unsubscribed)
    end

    def perform
      match_and_update_contacts
      # Process remaining audience that aren't in the database
      # relies on matches being deleted in previous step
      process_remaining_contacts
    end

    private

    def match_and_update_contacts
      # Ignore pupils and school onboarding users
      User.where.not(role: [:pupil, :school_onboarding]).find_each do |user|
        if in_mailchimp_audience?(user)
          mailchimp_contact_type = mailchimp_contact_type(user.email)
          # remove matches
          contact = @audience[mailchimp_contact_type].delete(user.email)
          # update user
          @updated_audience[mailchimp_contact_type] << user_to_mailchimp(user, contact)
        else
          @new_nonsubscribed << user_to_mailchimp(user)
        end
      end
    end

    def process_remaining_contacts
      @audience.each do |category, contacts|
        updated_audience[category] = updated_audience[category] + contacts.map {|c| process_contact(c) }
      end
    end

    # convert User to mailchimp contact, preserving exiting fields if given
    # TODO
    def user_to_mailchimp(user, existing_contact = nil)
      contact = ActiveSupport::OrderedOptions.new
      contact.email_address = user.email
      contact.name = user.name
      contact.contact_source = 'User'
      contact.confirmed_date = user.confirmed_at.to_date.iso8601
      contact.user_role = user.role.humanize
      contact.locale = user.preferred_locale

      # TODO naming
      if existing_contact && existing_contact[:interests]
        # If this is present then we're updating an existing contact that should
        # have Newsletter set already
        contact.interests = existing_contact[:interests]
      else
        contact.interests = 'Newsletter'
      end

      # TODO cluster users
      if user.school.present?
        contact.staff_role = user&.staff_role&.title
        contact.alert_subscriber = user.contacts.for_school(user.school).any? ? 'Yes' : 'No'
        contact.school = user.school&.name
        contact.school_status = if user.school.deleted?
                                  'Deleted'
                                elsif user.school.archived?
                                  'Archived'
                                else
                                  'Active'
                                end
        contact.scoreboard = user.school&.scoreboard&.name
        contact.school_group = user.school&.school_group&.name
        contact.local_authority = user.school&.local_authority_area&.name
        contact.region = user.school&.region&.humanize
        contact.country = user.school.country&.humanize
        contact.funder = user.school&.funder&.name

        existing_tags = non_free_school_meal_tags(existing_contact)
        if existing_tags.any?
          contact.tags = "#{existing_tags.join(',')},#{MailchimpTags.new(user.school).tags}"
        else
          contact.tags = MailchimpTags.new(user.school).tags
        end
      elsif user.group_admin?
        contact.alert_subscriber = 'No'
        contact.scoreboard = user.school_group&.default_scoreboard&.name
        contact.school_group = user.school_group&.name
        contact.country = user.school_group&.default_country&.humanize
        contact.tags = existing_contact[:tags] if existing_contact
      end
      contact
    end

    def non_free_school_meal_tags(existing_contact)
      return [] unless existing_contact.present? && existing_contact[:tags].present?
      existing_contact[:tags].split(',').reject {|t| t.match?(/FSM/) }
    end

    # TODO: may need to work before/after schema changes?
    def process_contact(contact)
    end

    def in_mailchimp_audience?(user)
      !mailchimp_contact_type(user.email).nil?
    end

    def mailchimp_contact_type(email_address)
      @audience.each do |category, hash|
        return category if hash.key?(email_address)
      end
      nil
    end

    def mailchimp_contact(email_address)
      mailchimp_contact_type = mailchimp_contact_type(email_address)
      return nil if mailchimp_contact_type.nil?
      @audience[mailchimp_contact_type][email_address]
    end

    def populate_audience(**categories)
      categories.each do |category, list|
        @audience[category] = list_to_hash(list)
      end
    end

    def list_to_hash(list)
      list.index_by {|c| c[:email_address].downcase}
    end
  end
end
