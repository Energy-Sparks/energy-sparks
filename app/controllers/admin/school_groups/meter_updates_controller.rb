module Admin
  module SchoolGroups
    class MeterUpdatesController < AdminController
      load_and_authorize_resource :school_group

      def index
      end
    end
  end
end
