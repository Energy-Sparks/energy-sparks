module Mailchimp
  class Contact
    include ActiveModel::Validations

    # Mailchimp core fields
    attr_accessor :email_address, :interests, :tags

    # our Merge Fields
    attr_accessor :alert_subscriber, :confirmed_date, :contact_source, :country, :funder, :locale, :local_authority, :name, :region, :staff_role, :school, :school_url, :school_group, :school_slug, :school_group_url, :school_group_slug, :school_status, :school_type, :scoreboard, :scoreboard_url, :user_role, :user_status

    validates_presence_of :email_address, :name

    def initialize(email_address, name)
      @email_address = email_address
      @name = name
      @interests = {}
      @tags = []
    end

    def self.from_user(user, tags: [], interests: {})
      unless user.active?
        return self.from_params({
          email_address: user.email,
          name: user.name,
          school: user.mailchimp_organisation,
          interests: {}
        })
      end

      contact = self.new(user.email, user.name)
      contact.contact_source = 'User'
      contact.confirmed_date = user.confirmed_at.to_date.iso8601
      contact.user_role = user.role.humanize
      contact.user_status = 'Active'
      contact.locale = user.preferred_locale
      contact.interests = interests

      if user.admin?
        contact.tags = self.non_fsm_tags(tags)
      elsif user.group_user?
        contact.alert_subscriber = user.contacts.any? ? 'Yes' : 'No'
        contact.scoreboard = user.school_group&.default_scoreboard&.name
        contact.scoreboard_url = "https://energysparks.uk/scoreboards/#{user.school_group.default_scoreboard.slug}" if user.school_group&.default_scoreboard
        contact.school_group = user.school_group&.name
        contact.school_group_url = "https://energysparks.uk/school_groups/#{user.school_group.slug}"
        contact.school_group_slug = user.school_group.slug
        contact.country = user.school_group&.default_country&.humanize
        contact.tags = self.non_fsm_tags(tags)
      elsif user.school_admin? && user.has_other_schools?
        contact.user_role = 'Cluster admin'
        contact.staff_role = user&.staff_role&.title
        contact.alert_subscriber = user.contacts.any? ? 'Yes' : 'No'
        contact.scoreboard = user.school.school_group&.default_scoreboard&.name
        if user.school.school_group&.default_scoreboard
          contact.scoreboard_url = "https://energysparks.uk/scoreboards/#{user.school.school_group.default_scoreboard.slug}"
        end
        contact.school_group = user.school.school_group&.name
        contact.school_group_url = "https://energysparks.uk/school_groups/#{user.school.school_group.slug}" if user.school.school_group
        contact.school_group_slug = user.school.school_group&.slug
        contact.country = user.school.school_group&.default_country&.humanize
        contact.tags = self.tags_for_school_user(user, tags, user.cluster_schools.map(&:slug), fsm_tags: false)
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
        contact.school_type = user.school.school_type.humanize
        contact.school_url = "https://energysparks.uk/schools/#{user.school.slug}"
        contact.school_slug = user.school.slug
        contact.scoreboard = user.school&.scoreboard&.name
        contact.scoreboard_url = "https://energysparks.uk/scoreboards/#{user.school.scoreboard.slug}" if user.school.scoreboard
        contact.school_group = user.school&.school_group&.name
        contact.school_group_url = "https://energysparks.uk/school_groups/#{user.school.school_group.slug}" if user.school.school_group
        contact.school_group_slug = user.school&.school_group&.slug
        contact.local_authority = user.school&.local_authority_area&.name
        contact.region = user.school&.region&.humanize
        contact.country = user.school.country&.humanize
        contact.funder = user.school&.funder&.name
        contact.tags = self.tags_for_school_user(user, tags, [user.school.slug])
      end
      contact
    end

    def self.from_params(params)
      contact = self.new(params[:email_address], params[:name])
      contact.school = params[:school]
      contact.contact_source = 'Organic'
      contact.interests = params[:interests].transform_values {|v| v == 'true' }
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
    def self.tags_for_school_user(user, existing_tags = [], slugs = [], fsm_tags: true)
      core_tags = slugs
      core_tags = core_tags + self.free_school_meal_tags(user.school) if fsm_tags
      existing_tags = self.non_fsm_tags(existing_tags)
      (core_tags + existing_tags)
    end

    # Parse existing tags in Mailchimp export, removing any free school meal tags as
    # these will be refreshed from the database.
    def self.non_fsm_tags(existing_tags)
      return [] unless existing_tags.present?
      existing_tags.reject {|t| t.match?(/FSM/) }
    end

    def self.free_school_meal_tags(school)
      tags = []
      return tags unless school.percentage_free_school_meals
      percent = school.percentage_free_school_meals
      if percent >= 30
        tags << 'FSM30'
      elsif percent >= 25
        tags << 'FSM25'
      elsif percent >= 20
        tags << 'FSM20'
      elsif percent >= 15
        tags << 'FSM15'
      end
      tags
    end


    # All the email types
    # Using the names rather than the ids, as this allows us to test against the
    # developer account
    GETTING_THE_MOST = 'Getting the most out of Energy Sparks'.freeze
    ENGAGING_PUPILS = 'Engaging pupils in energy saving and climate'.freeze
    LEADERSHIP = 'Energy saving leadership'.freeze
    TAILORED_ADVICE = 'Tailored advice and support'.freeze
    TRAINING = 'Training opportunities'.freeze

    LEADERSHIP_INTERESTS = [GETTING_THE_MOST, TRAINING, TAILORED_ADVICE, LEADERSHIP].freeze
    TEACHING_INTERESTS =   [GETTING_THE_MOST, TRAINING, TAILORED_ADVICE, ENGAGING_PUPILS].freeze

    ALL_INTERESTS = [GETTING_THE_MOST, TRAINING, TAILORED_ADVICE, LEADERSHIP, ENGAGING_PUPILS].freeze

    SCHOOL_USER_INTERESTS = {
      'Business manager' => LEADERSHIP_INTERESTS,
      'Building/site manager or caretaker' => LEADERSHIP_INTERESTS,
      'Governor' => LEADERSHIP_INTERESTS,
      'Teacher or teaching assistant' => TEACHING_INTERESTS,
      'Headteacher or Deputy Head' => ALL_INTERESTS,
      'Council or MAT staff' => LEADERSHIP_INTERESTS,
      'Parent or volunteer' => TEACHING_INTERESTS,
      'Public' => [GETTING_THE_MOST, TRAINING, TAILORED_ADVICE]
    }.freeze

    ORGANIC_SIGN_UP_INTERESTS = [GETTING_THE_MOST, ENGAGING_PUPILS, LEADERSHIP].freeze

    # Take Array of interests returned by AudienceManager and turn into hash
    # for use on forms, setting the default opt-in state.
    def self.default_interests(interests, user = nil)
      interest_list = if user&.group_user?
                        ALL_INTERESTS
                      elsif user&.staff_role && SCHOOL_USER_INTERESTS.key?(user.staff_role.title)
                        SCHOOL_USER_INTERESTS[user.staff_role.title]
                      else
                        ORGANIC_SIGN_UP_INTERESTS
                      end
      interests.to_h do |interest|
        [interest.id, interest_list.include?(interest.name)]
      end
    end

    # Convert to hash for submitting to mailchimp api
    def to_mailchimp_hash
      {
        "email_address": email_address,
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
        'GROUP_SLUG' => school_group_slug || '',
        'GROUP_URL' => school_group_url || '',
        'LA' => local_authority || '',
        'LOCALE' => locale || '',
        'REGION' => region || '',
        'SCHOOL' => school || '',
        'SCHOOL_URL' => school_url || '',
        'SCOREBOARD' => scoreboard || '',
        'SCORE_URL' => scoreboard_url || '',
        'SGROUP' => school_group || '',
        'SOURCE' => contact_source || '',
        'SSLUG' => school_slug || '',
        'SSTATUS' => school_status || '',
        'STYPE' => school_type || '',
        'STAFFROLE' => staff_role || '',
        'USERROLE' => user_role || '',
        'USERSTATUS' => user_status || ''
      }
    end
  end
end
