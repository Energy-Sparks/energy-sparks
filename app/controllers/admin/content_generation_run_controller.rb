module Admin
  class ContentGenerationRunController < AdminController
    def create
      school = School.find(params[:school_id])
      Alerts::GenerateContent.new(school).perform
      redirect_back fallback_location: admin_alert_types_path, notice: "Content regenerated for #{school.name}"
    end
  end
end
