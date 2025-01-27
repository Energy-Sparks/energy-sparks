module Mailchimp
  class UpdateCreator
    def initialize(model)
      @model = model
    end

    def self.for(model)
      "Mailchimp::#{model.class.name}UpdateCreator".constantize.new(model)
    rescue
      nil
    end

    def perform
      return false unless updates_required?
      create_updates(contacts)
      true
    end

    private

    def updates_required?
      raise 'Not implemented'
    end

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
  end

  # TODO tags
  class UserUpdateCreator < UpdateCreator
    # TODO fields
    def updates_required?
      @model.name_previously_changed?
    end

    def contacts
      [@model]
    end
  end
end
