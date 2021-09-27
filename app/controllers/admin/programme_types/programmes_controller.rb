module Admin
  module ProgrammeTypes
    class ProgrammesController < AdminController
      load_resource :programme_type
      load_and_authorize_resource through: :programme_type

      def index
        @programmes = @programmes.sort_by { |programme| programme.school.name }
        @activity_types_count = @programme_type.activity_types.count
      end
    end
  end
end
