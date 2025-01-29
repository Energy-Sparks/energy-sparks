module Mailchimp
  class UpdateCreator
    # subclasses should redefine as required
    FIELDS = [].freeze

    def initialize(model)
      @model = model
    end

    def self.for(model)
      "Mailchimp::#{model.class.name}UpdateCreator".constantize.new(model)
    rescue
      nil
    end

    # TODO
    def submit_job
    end

    def updates_required?
      @model.previous_changes.symbolize_keys.keys.any? { |k| self.class::FIELDS.include?(k) }
    end

    def perform
      create_updates(contacts)
      true
    end

    private

    def contacts
      raise 'Not implemented'
    end

    # TODO tags, could override and call base class multiple times
    # or pass in update_types as all contacts will also need tagging?
    # or a flag? Only need tags if school is added to user, or free schools meals change
    def create_updates(contacts)
      Mailchimp::Update.upsert_all(
        contacts.map {|c| { user_id: c.id, status: :pending, update_type: :update_contact } },
        unique_by: [:user_id, :status, :update_type],
        record_timestamps: true,
        returning: false
      )
    end

    def all_school_users_where(**where)
      contacts = []
      School.where(where).find_each do |school|
        contacts += school.all_adult_school_users
      end
      contacts.uniq
    end
  end

  # TODO tags
  class UserUpdateCreator < UpdateCreator
    FIELDS = [:confirmed_at, :email, :name, :preferred_locale, :school_id, :school_group_id, :role, :staff_role_id].freeze

    def contacts
      [@model]
    end
  end

  class SchoolUpdateCreator < UpdateCreator
    FIELDS = [:active, :country, :funder_id, :local_authority_area_id, :name, :region, :school_group_id, :school_type, :scoreboard_id].freeze

    def contacts
      @model.all_adult_school_users
    end
  end

  class SchoolGroupUpdateCreator < UpdateCreator
    FIELDS = [:name].freeze

    # FIXME scopes?
    def contacts
      contacts = @model.users
      @model.schools.each do |school|
        contacts += school.all_adult_school_users
      end
      contacts.uniq
    end
  end

  class FunderUpdateCreator < UpdateCreator
    FIELDS = [:name].freeze

    def contacts
      all_school_users_where(funder: @model)
    end
  end

  class LocalAuthorityAreaUpdateCreator < UpdateCreator
    FIELDS = [:name].freeze

    def contacts
      all_school_users_where(local_authority_area: @model)
    end
  end

  class StaffRoleUpdateCreator < UpdateCreator
    FIELDS = [:title].freeze

    def contacts
      User.where(staff_role: @model)
    end
  end

  class ScoreboardUpdateCreator < UpdateCreator
    FIELDS = [:name].freeze

    # Group admins for default?
    def contacts
      all_school_users_where(scoreboard: @model)
    end
  end

  # FIXME, need to handle insert and delete, no updates???
  class ContactUpdateCreator < UpdateCreator
  end
end
