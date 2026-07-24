# frozen_string_literal: true

module RecordingScopes
  extend ActiveSupport::Concern

  included do
    scope :for_school, ->(school) { where(school:) }
    scope :for_school_group, ->(school_group) { where(school: { school_group: school_group }) }
    scope :for_admin, ->(admin) { where(school: { school_groups: { default_issues_admin_user: admin } }) }
    scope :for_user_role, ->(user_role) { where(created_by: { role: user_role }) }
  end
end
