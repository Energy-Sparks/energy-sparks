# frozen_string_literal: true

module Admin
  class QuickLinksComponent < ApplicationComponent
    def initialize(user:, **)
      super(**)
      @user = user
    end

    def search_cards
      [
        { name: :school_group, url: admin_dashboard_path(@user), options: school_groups.by_name.pluck(:name, :slug),
          prompt: 'select a school group', submit: 'Manage' },
        { name: 'mpxn', url: admin_find_school_by_mpxn_index_path, submit: 'Find MPXN' },
        { name: :school, url: admin_dashboard_path(@user), options: schools.by_name.pluck(:name, :slug),
          prompt: 'select a school', submit: 'Manage' },
        { name: 'urn', url: admin_find_school_by_urn_index_path, submit: 'Find URN' }
      ]
    end

    def school_groups
      SchoolGroup.where(default_issues_admin_user: @user).with_active_schools.by_name
    end

    def schools
      School.active
            .joins(:school_group)
            .where(school_group: { default_issues_admin_user_id: @user.id })
            .select(:id, :name)
            .order(:name)
    end
  end
end
