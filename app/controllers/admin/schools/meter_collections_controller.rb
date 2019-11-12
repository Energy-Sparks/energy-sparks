module Admin
  module Schools
    class MeterCollectionsController < AdminController
      def index
        @school_groups = SchoolGroup.includes(:schools).where.not(schools: { id: nil }).order(:name)
      end
    end
  end
end
