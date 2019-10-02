module Admin
  class ContentGenerationRunController < AdminController
    def create
      School.all.each do |school|
        Alerts::GenerateContent.new(school).perform
      end
      redirect_back fallback_location: admin_alert_types_path, notice: 'Content regenerated'
    end
  end
end
