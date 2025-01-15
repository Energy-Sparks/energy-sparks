module Mailchimp
  # Mailchimp defines an Audience as a list of Contacts. These contacts are
  # classified into different types (https://mailchimp.com/help/about-your-contacts/)
  # When an Audience is exported there are 4 CSV files, one for each contact type.
  #
  # This service accepts lists of Contacts parsed from a Mailchimp Audience export
  # It processes these to normalise and update the data associated with each contact
  # so that it matches our preferred schema.
  #
  # This allows us to migrate to a richer set of data in Mailchimp, whilst also allowing
  # the contact data to be refreshed against the database.
  #
  # The original contact types are preserved to ensure we protect user's consent.
  #
  # As some users have signed up with Mailchimp, but are not registered users the
  # service preserves those contacts so no data is lost. Fields are still normalised
  # to match the preferred schema.
  #
  # The service will also produce a list of new "nonsubscribed" users from the
  # database. These are users that are not currently subscribed to any emails.
  # This is to allow us to use Mailchimp for some transactional emails with those
  # users, as well as checking whether they want to opt into the newsletter or other
  # comms as a one-off basis.
  #
  # The service will be driven by a Rake task that parses Mailchimp CSV files and
  # dumps the new versions for manual importing into Mailchimp.
  class CsvExporter
    # A hash containing an entry for each of the four Mailchimp contact types.
    # The entry in each list is an object that can be dumped to a CSV file
    attr_reader :updated_audience
    # A list of new contacts. These are users not currently in the Mailchimp Audience.
    attr_reader :new_nonsubscribed

    # Initialise with lists of hashed fields parsed from Mailchimp export
    def initialize(subscribed:, nonsubscribed:, cleaned:, unsubscribed:)
      @audience = {}
      @updated_audience = { subscribed: [], nonsubscribed: [], cleaned: [], unsubscribed: [] }
      @new_nonsubscribed = []
      populate_audience(subscribed: subscribed, nonsubscribed: nonsubscribed, cleaned: cleaned, unsubscribed: unsubscribed)
    end

    # Match contacts against database, updating with latest data and mapping to
    # preferred schema
    #
    # Also find any unmatched users that copy those through, normalising fields if
    # required.
    def perform
      match_and_update_contacts
      # relies on matched users being deleted in previous step
      process_unmatched_contacts
    end

    private

    # Ignore pupils and school onboarding users, process all other user types
    def match_and_update_contacts
      User.where.not(role: [:pupil, :school_onboarding]).where.not(confirmed_at: nil).find_each do |user|
        if in_mailchimp_audience?(user)
          mailchimp_contact_type = mailchimp_contact_type(user.email)
          # remove matches from list
          contact = @audience[mailchimp_contact_type].delete(user.email)
          # update user
          @updated_audience[mailchimp_contact_type] << to_mailchimp_contact(user, contact)
        else
          @new_nonsubscribed << to_mailchimp_contact(user, newsletter_subscriber: false)
        end
      end
    end

    # Process any Mailchimp contacts that are not registered users
    def process_unmatched_contacts
      @audience.each do |category, contacts|
        updated_audience[category] = updated_audience[category] + contacts.values.map {|c| copy_contact(c) }
      end
    end

    def to_mailchimp_contact(user, existing_contact = nil, newsletter_subscriber: true)
      # Convert from comma-separated names to hash
      interests = if existing_contact.present? && existing_contact[:interests].present?
                    existing_contact[:interests].split(',').index_with { |_i| true }
                  else
                    {}
                  end
      interests['Newsletter'] = true if newsletter_subscriber
      tags = existing_contact.present? && existing_contact[:tags].present? ? existing_contact[:tags].split(',') : []
      contact = Mailchimp::Contact.from_user(user, tags: tags, interests: interests)

      # For CSV we just join tags into single field
      contact.tags = contact.tags.join(',')
      # For CSV we use the name of the groups
      contact.interests = contact.interests.keys.join(',')
      contact
    end

    # Create the tags for school users and cluster admins
    #
    # The core set of tags are:
    # - a tag for different % of free school meals at the school
    # - a tag for the school slug (and one for each cluster school)
    # - any existing tags are preserved
    #
    # Cluster admins will not have free school meal tags.
    def tags_for_school_user(user, existing_contact = nil, slugs = [], fsm_tags: true)
      core_tags = slugs
      core_tags = core_tags + MailchimpTags.new(user.school).tags_as_list if fsm_tags
      existing_tags = non_fsm_tags(existing_contact)
      (core_tags + existing_tags).join(',')
    end

    # Parse existing tags in Mailchimp export, removing any free school meal tags as
    # these will be refreshed from the database.
    def non_fsm_tags(existing_contact)
      return [] unless existing_contact.present? && existing_contact[:tags].present?
      existing_contact[:tags].split(',').reject {|t| t.match?(/FSM/) }
    end

    # Copies a Mailchimp contact that is not a registered user.
    #
    # We don't just pass through the current details as we may need to normalise some of
    # the fields. So check whether those fields exist and copy them through before remapping
    # any older fields.
    #
    # This is to allow for migration to be re-run before we tidy up and remove some of
    # the old fields.
    def copy_contact(existing_contact)
      # TODO use new model
      contact = ActiveSupport::OrderedOptions.new
      contact.email_address = existing_contact[:email_address]
      contact.contact_source = 'Organic'
      contact.locale = 'en'
      contact.tags = non_fsm_tags(existing_contact).join(',')

      # If this is present then we're updating an existing contact that should
      # have Newsletter set already
      # TODO naming
      contact.interests = existing_contact[:interests] || 'Newsletter'

      first_and_last_name_fields = existing_contact[:first_name] && existing_contact[:last_name]
      first_and_name_fields = existing_contact[:first_name] && existing_contact[:name] && !existing_contact[:name].include?(existing_contact[:first_name])

      if first_and_last_name_fields # older Mailchimp only fields
        contact.name = [existing_contact[:first_name], existing_contact[:last_name]].join(' ')
      elsif first_and_name_fields # some users have entered first/last names into the first_name and name fields
        contact.name = [existing_contact[:first_name], existing_contact[:name]].join(' ')
      elsif existing_contact[:name] # if set, this is usually full name
        contact.name = existing_contact[:name]
      else # combine whatever name fields we have
        contact.name = [existing_contact[:first_name], existing_contact[:last_name]].join('')
      end

      contact.staff_role = existing_contact[:staff_role] || existing_contact[:user_type]
      contact.school = existing_contact[:school] || existing_contact[:school_or_organisation]

      if existing_contact[:school_group].present?
        contact.school_group = existing_contact[:school_group]
      else
        # :local_authority_and_mats is the current field, but not all groups are present
        # due to limitations in number of groups in Mailchimp.
        #
        # So use the "other" fields presented to users on the mailchimp form in preference as
        # these are hopefully more accurate, otherwise fall back to the current field.
        contact.school_group = if existing_contact[:other_mat].present?
                                 existing_contact[:other_mat]
                               elsif existing_contact[:other_la].present?
                                 existing_contact[:other_la]
                               else
                                 existing_contact[:local_authority_and_mats]
                               end
      end
      contact
    end

    # Is this user in Mailchimp? Check each of the 4 contact types
    def in_mailchimp_audience?(user)
      !mailchimp_contact_type(user.email).nil?
    end

    # Identify the contact type for this email address.
    def mailchimp_contact_type(email_address)
      @audience.each do |category, hash|
        return category if hash.key?(email_address)
      end
      nil
    end

    # Lookup the mailchimp contact for an email address, by way of its
    # contact type
    def mailchimp_contact(email_address)
      mailchimp_contact_type = mailchimp_contact_type(email_address)
      return nil if mailchimp_contact_type.nil?
      @audience[mailchimp_contact_type][email_address]
    end

    # Take lists provided in constructor and build an internal hash:
    # contact type => hash (email_address => exported contact)
    def populate_audience(**categories)
      categories.each do |category, list|
        @audience[category] = list_to_hash(list)
      end
    end

    # Convert list of exported contacts to a hash, normalising emails as Mailchimp
    # allows mixed case whereas application is all lower case.
    def list_to_hash(list)
      list.index_by {|c| c[:email_address].downcase}
    end
  end
end
