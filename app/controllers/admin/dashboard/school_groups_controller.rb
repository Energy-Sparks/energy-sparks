# frozen_string_literal: true

module Admin
  module Dashboard
    class SchoolGroupsController < Admin::SchoolGroupsController
      include AdminDashboard

      before_action :set_metadata

      def index
        super
        @school_groups = @school_groups.where(default_issues_admin_user: @admin) if @admin
      end

      def title
        'School Groups'
      end
    end
  end
end
