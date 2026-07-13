# frozen_string_literal: true

module Admin
  module Reports
    class LimitedUsersController < AdminController
      def index
        @schools = School.visible.limited_users.by_name
      end
    end
  end
end
