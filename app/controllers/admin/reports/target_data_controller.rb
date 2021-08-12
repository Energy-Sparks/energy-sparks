module Admin
  module Reports
    class TargetDataController < AdminController
      def index
        @school_groups = SchoolGroup.order(:name)
        @report = generate_report_for_group
        respond_to do |format|
          format.csv  { send_data report_to_csv(@report), filename: "#{params[:school_group_id].parameterize}.csv" }
          format.html { render :index }
        end
      end

      private

      def generate_report_for_group
        if params[:school_group_id].present?
          @school_group = SchoolGroup.find(params[:school_group_id])
          return ::Schools::GroupTargetDataReportService.new(@school_group).report
        end
        {}
      end

      def report_to_csv(report)
        StringIO.open do |s|
          s.puts CSV.generate_line(
            ["School", "Visible?", "Fuel Type", "Enough calendar data?", "Enough AMR data?", "School target already set?"]
          )
          report.each do |school, result|
            result.each do |fuel_result|
              s.puts CSV.generate_line([school.name,
                                        school.visible,
                                        fuel_result[:fuel_type],
                                        fuel_result[:calendar_data],
                                        fuel_result[:amr_data],
                                        fuel_result[:current_target]])
            end
          end
          s.string
        end
      end
    end
  end
end
