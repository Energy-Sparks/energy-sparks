module Admin
  module AlertTypes
    class FindOutMoreTypesController < AdminController
      load_and_authorize_resource :alert_type

      def index
        @find_out_more_types = @alert_type.find_out_more_types.order(rating_from: :asc)
      end

      def new
        @find_out_more_type = FindOutMoreType.new
        @content = FindOutMoreTypeContentVersion.new
      end

      def create
        @find_out_more_type = @alert_type.find_out_more_types.new(find_out_more_type_params)
        @content = @find_out_more_type.content_versions.new(content_params[:content])
        if @find_out_more_type.update_with_content!(@content)
          redirect_to admin_alert_type_find_out_more_types_path(@alert_type), notice: 'Find Out More type created'
        else
          render :new
        end
      end


    private

      def find_out_more_type_params
        params.require(:find_out_more_type).permit(
          :description, :rating_from, :rating_to
        )
      end

      def content_params
        params.require(:find_out_more_type).permit(
          content: [:dashboard_title, :page_title, :page_content]
        )
      end
    end
  end
end
