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
  class CsvExporter < BaseAudienceExportProcessorService
    # A hash containing an entry for each of the four Mailchimp contact types.
    # The entry in each list is an object that can be dumped to a CSV file
    attr_reader :updated_audience
    # A list of new contacts. These are users not currently in the Mailchimp Audience.
    attr_reader :new_nonsubscribed

    # Initialise with lists of hashed fields parsed from Mailchimp export
    def initialize(subscribed:, nonsubscribed:, cleaned:, unsubscribed:, add_default_interests: false)
      super(subscribed:, nonsubscribed:, cleaned:, unsubscribed:)
      @updated_audience = { subscribed: [], nonsubscribed: [], cleaned: [], unsubscribed: [] }
      @new_nonsubscribed = []
      @add_default_interests = add_default_interests
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
      User.mailchimp_roles.find_each do |user|
        if in_mailchimp_audience?(user)
          mailchimp_contact_type = mailchimp_contact_type(user.email)
          # remove matches from list
          contact = @audience[mailchimp_contact_type].delete(user.email)
          # update user, only adding default interests if we're overriding current prefs
          @updated_audience[mailchimp_contact_type] << to_mailchimp_contact(user, contact, add_default_interests: @add_default_interests)
        else
          # always add default interests
          @new_nonsubscribed << to_mailchimp_contact(user, add_default_interests: true)
        end
      end
    end

    # Process any Mailchimp contacts that are not registered users
    # Only add default interests if overriding current prefs
    def process_unmatched_contacts
      @audience.each do |category, contacts|
        updated_audience[category] = updated_audience[category] + contacts.values.map {|c| copy_contact(c, add_default_interests: @add_default_interests) }
      end
    end

    def to_mailchimp_contact(user, existing_contact = nil, add_default_interests: false)
      # Convert from comma-separated names to hash
      interests = if existing_contact.present? && existing_contact[:interests].present?
                    existing_contact[:interests].split(',').index_with { |_i| true }
                  else
                    {}
                  end

      interests = default_interests(interests, user) if add_default_interests

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
      core_tags = core_tags + self.free_school_meal_tags(user.school) if fsm_tags
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
    def copy_contact(existing_contact, add_default_interests: false)
      # TODO use new model
      contact = ActiveSupport::OrderedOptions.new
      contact.email_address = existing_contact[:email_address]
      contact.contact_source = 'Organic'
      contact.locale = 'en'
      contact.tags = non_fsm_tags(existing_contact).join(',')

      # If this is present then we're updating an existing contact that should
      # have Newsletter set already
      # TODO naming
      contact.interests = add_default_interests ? default_interests(existing_contact[:interests]) : existing_contact[:interests]

      # FIXME old fields have been removed, so simplify
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

    def default_interests(interests, user = nil)
      # hash of id to value
      defaults = Mailchimp::Contact.default_interests(email_types, user)

      id_to_name = email_types.to_h { |i| [i.id, i.name] }
      named_defaults = defaults.transform_keys {|k| id_to_name[k] }
      named_defaults.reject! { |_k, v| !v }
      interests ? interests.merge(named_defaults) : named_defaults
    end

    def audience_manager
      @audience_manager ||= Mailchimp::AudienceManager.new
    end

    def email_types
      @email_types ||= list_of_email_types
    end

    def list_of_email_types
      category = audience_manager.categories.detect {|c| c.title == 'Interests' }
      return [] unless category
      return audience_manager.interests(category.id)
    rescue => e
      Rails.logger.error(e)
      Rollbar.error(e)
      []
    end
  end
end
