# frozen_string_literal: true

module Admin
  module Reports
    class MissingAlertContactsController < AdminController
      def index
        @schools = School.joins(:school_group).visible.missing_alert_contacts.by_name
      end
    end
  end
end
