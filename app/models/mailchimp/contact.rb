module Mailchimp
  class Contact
    include ActiveModel::Validations

    # Mailchimp fields
    attr_accessor :email_address, :interests, :tags

    # our Merge Fields
    # TODO add school, school group and scoreboard urls as fields
    attr_accessor :alert_subscriber, :confirmed_date, :contact_source, :country, :funder, :locale, :local_authority, :name, :region, :staff_role, :school, :school_group, :school_status, :scoreboard, :user_role

    validates_presence_of :email_address

    def initialize(email_address)
      @email_address = email_address
      @interests = {}
      @tags = []
    end

    def self.from_user(user, tags: [], interests: {})
      contact = self.new(user.email)
      contact.email_address = user.email
      contact.name = user.name
      contact.contact_source = 'User'
      contact.confirmed_date = user.confirmed_at.to_date.iso8601
      contact.user_role = user.role.humanize
      contact.locale = user.preferred_locale
      contact.interests = interests

      if user.admin?
        contact.tags = self.non_fsm_tags(tags)
      elsif user.group_admin?
        contact.alert_subscriber = user.contacts.any? ? 'Yes' : 'No'
        contact.scoreboard = user.school_group&.default_scoreboard&.name
        contact.school_group = user.school_group&.name
        contact.country = user.school_group&.default_country&.humanize
        contact.tags = self.non_fsm_tags(tags)
      elsif user.school_admin? && user.has_other_schools?
        contact.user_role = 'Cluster admin'
        contact.staff_role = user&.staff_role&.title
        contact.alert_subscriber = user.contacts.any? ? 'Yes' : 'No'
        contact.scoreboard = user.school.school_group&.default_scoreboard&.name
        contact.school_group = user.school.school_group&.name
        contact.country = user.school.school_group&.default_country&.humanize
        contact.tags = self.tags_for_school_user(user, tags, [user.cluster_schools.map(&:slug)], fsm_tags: false)
      elsif user.school.present?
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
        contact.tags = self.tags_for_school_user(user, tags, [user.school.slug])
      end
      contact
    end

    # TODO already expressed using merge fields?
    def self.from_params(params)
    end

    # Create the tags for school users and cluster admins
    #
    # The core set of tags are:
    # - a tag for different % of free school meals at the school
    # - a tag for the school slug (and one for each cluster school)
    # - any existing tags are preserved
    #
    # Cluster admins will not have free school meal tags.
    def self.tags_for_school_user(user, existing_tags = [], slugs = [], fsm_tags: true)
      core_tags = slugs
      core_tags = core_tags + MailchimpTags.new(user.school).tags_as_list if fsm_tags
      existing_tags = self.non_fsm_tags(existing_tags)
      (core_tags + existing_tags)
    end

    # Parse existing tags in Mailchimp export, removing any free school meal tags as
    # these will be refreshed from the database.
    def self.non_fsm_tags(existing_tags)
      return [] unless existing_tags.present?
      existing_tags.reject {|t| t.match?(/FSM/) }
    end

    # Convert to hash for submitting to mailchimp api
    def to_mailchimp_hash(status = 'subscribed')
      {
        "email_address": email_address,
        "status": status,
        "merge_fields": merge_fields,
        "interests": interests,
        "tags": tags
      }
    end

    private

    def merge_fields
      {
        'ALERTSUBS' => alert_subscriber || '',
        'CONFIRMED' => confirmed_date || '',
        'COUNTRY' => country || '',
        'FULLNAME' => name || '',
        'FUNDER' => funder || '',
        'LA' => local_authority || '',
        'LOCALE' => locale || '',
        'REGION' => region || '',
        'SCHOOL' => school || '',
        'SCOREBOARD' => scoreboard || '',
        'SGROUP' => school_group || '',
        'SOURCE' => contact_source || '',
        'SSTATUS' => school_status || '',
        'STAFFROLE' => staff_role || '',
        'USERROLE' => user_role || ''
      }
    end
  end
end
