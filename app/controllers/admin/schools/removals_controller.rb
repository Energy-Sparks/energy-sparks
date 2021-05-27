module Admin
  module Schools
    class RemovalsController < AdminController
      def index
        @schools = School.inactive
      end
    end
  end
end
