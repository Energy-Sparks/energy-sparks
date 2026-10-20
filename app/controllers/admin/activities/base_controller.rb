# frozen_string_literal: true

module Admin
  module Activities
    class BaseController < AdminController
      layout 'admin_activities'

      before_action :enable_bootstrap5
      before_action :set_breadcrumbs

      private

      def set_breadcrumbs
        @breadcrumbs = [
          { name: 'Admin', href: admin_path },
          { name: 'Activities & Actions', href: admin_activities_root_path }
        ]
      end
    end
  end
end
