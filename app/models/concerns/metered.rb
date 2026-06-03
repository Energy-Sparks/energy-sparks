module Metered
  extend ActiveSupport::Concern

  included do
    belongs_to :meter

    scope :with_meter_school_and_group, -> { includes(:meter, meter: [:school, { school: :school_group }]) }
    scope :for_school_group, ->(school_group) { where(meter: { schools: { school_group: school_group } }) }
    scope :for_admin, ->(admin) { where(meter: { schools: { school_groups: { default_issues_admin_user: admin } } }) }
    scope :default_order, -> { order(:meter_id, :reading_date) }
  end
end
