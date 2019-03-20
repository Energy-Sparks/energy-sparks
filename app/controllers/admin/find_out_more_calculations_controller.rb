module Admin
  class FindOutMoreCalculationsController < AdminController
    def create
      schools = School.active
      schools.each do |school|
        Alerts::GenerateFindOutMores.new(school).perform
      end
      redirect_back fallback_location: admin_alert_types_path, notice: 'Find out more calculations updated'
    end
  end
end
