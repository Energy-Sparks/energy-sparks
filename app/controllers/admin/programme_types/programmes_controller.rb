module Admin
  module ProgrammeTypes
    class ProgrammesController < AdminController
      load_resource :programme_type
      load_and_authorize_resource through: :programme_type, only: :index

      def index
        @programmes = @programmes.sort_by { |programme| programme.school.name }
        @schools_to_enrol = School.by_name - @programmes.map(&:school).uniq
      end

      def create
        school = School.find(params[:programme][:school_id])
        Programmes::Enroller.new(@programme_type).enrol(school)
        redirect_to admin_programme_type_programmes_path(@programme_type), notice: "Enrolled #{school.name} in #{@programme_type.title}"
      end
    end
  end
end
