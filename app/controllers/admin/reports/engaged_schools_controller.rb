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
          csv << ['School Group', 'School', 'Funder', 'Country', 'Activities', 'Actions',
                  'Programmes', 'Target?', 'Transport survey?', 'Temperatures?',
                  'Active users', 'Last visit']
          engaged_schools.each do |service|
            csv << [
              service.school_group.name,
              service.school.name,
              service.school.funder.present? ? service.school.funder.name : nil,
              service.school.country.humanize,
              service.recent_activity_count,
              service.recent_action_count,
              service.recently_enrolled_programme_count,
              service.active_target? ? 'Y' : 'N',
              service.transport_surveys? ? 'Y' : 'N',
              service.temperature_recordings? ? 'Y' : 'N',
              service.recently_logged_in_user_count,
              service.most_recent_login.present? ? service.most_recent_login.iso8601 : nil
            ]
          end
        end
      end
    end
  end
end
