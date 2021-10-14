module Admin
  module Reports
    class MeterReportsController < AdminController
      def index
        @school_groups = SchoolGroup.includes(:schools).where.not(schools: { id: nil }).order(:name)
      end
    end
  end
end
