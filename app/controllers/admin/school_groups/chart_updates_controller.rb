module Admin
  module SchoolGroups
    class ChartUpdatesController < AdminController
      load_and_authorize_resource :school_group

      def index
      end

      def bulk_update_charts
        if @school_group.schools.update_all(chart_preference: default_chart_preference) && @school_group.update!(default_chart_preference: default_chart_preference)
          count = @school_group.schools.count
          notice = "Default chart preference successfully updated for #{@school_group.name} and #{count} #{'school'.pluralize(count)} in this group."
          redirect_to(admin_school_group_chart_updates_path(@school_group), notice: notice) and return
        else
          render :index, status: :unprocessable_entity
        end
      end

      private

      def default_chart_preference
        default_chart_preference_update_params['default_chart_preference']
      end

      def default_chart_preference_update_params
        params.require(:school_group).permit(:default_chart_preference)
      end
    end
  end
end
