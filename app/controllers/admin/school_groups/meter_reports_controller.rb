module Admin
  module SchoolGroups
    class MeterReportsController < AdminController
      load_and_authorize_resource :school_group
      def show
        @meter_scope = if params.key?(:all_meters)
                         {}
                       else
                         { active: true }
                       end
      end
    end
  end
end
