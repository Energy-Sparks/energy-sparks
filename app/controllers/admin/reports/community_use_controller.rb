module Admin
  module Reports
    class CommunityUseController < AdminController
      def index
        @schools = School.process_data.with_community_use.by_name
      end
    end
  end
end
