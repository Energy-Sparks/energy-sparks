module Admin
  module Reports
    class EngagedSchoolsController < AdminController
      def index
        respond_to do |format|
          format.html do
            @engaged_schools = ::Schools::EngagedSchoolService.list_engaged_schools
            @visible_schools = School.visible.count
            @percentage = percentage_engaged
          end
          format.csv do
            @engaged_schools = ::Schools::EngagedSchoolService.list_engaged_schools
            send_data csv_report(@engaged_schools), filename: "engaged-schools-report-#{Time.zone.now.iso8601}".parameterize + '.csv'
          end
        end
      end

      private

      def percentage_engaged
        sprintf('%.2f', @engaged_schools.size / @visible_schools.to_f * 100)
      end

      def csv_report(engaged_schools)
        CSV.generate(headers: true) do |csv|
          csv << []
          engaged_schools.each do |service|
            csv << [service.school.name]
          end
        end
      end
    end
  end
end
