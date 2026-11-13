# frozen_string_literal: true

module Admin
  module Reports
    class AmrValidatedReadingsController < AdminController
      def show
        @meter = Meter.includes(:amr_validated_readings).find(params[:meter_id])
        @school = @meter.school
        respond_to do |format|
          format.json do
            render json: Meters::DetailedCalendarGenerator.new(@meter).generate
          end
          format.html do
            @gappy_validated_readings = @meter.gappy_validated_readings
          end
        end
      end

      def summary
        @meter = Meter.includes(:amr_validated_readings).find(params[:meter_id])
        render json: Meters::SummarisedCalendarGenerator.new(@meter).generate
      end
    end
  end
end
