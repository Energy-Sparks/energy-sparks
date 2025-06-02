module Admin
  module Schools
    class MeterReviewsController < AdminController
      load_and_authorize_resource :school
      load_and_authorize_resource

      layout Flipper.enabled?(:new_manage_school_pages) ? 'dashboards' : 'application'

      def index
        @meter_reviews = @school.meter_reviews.order(:created_at)
      end

      def new
        @meter_review = MeterReview.new
        @consent_grant = @school.consent_grants.by_date.first
        @pending_meters = @school.meters.unreviewed_dcc_meter.order(:mpan_mprn)
      end

      def create
        meters = @school.meters.where(id: params[:meter_review]['meter_ids'])
        consent_documents = @school.consent_documents.where(id: params[:meter_review]['consent_document_ids'])
        service = MeterReviewService.new(@school, current_user)
        review = service.complete_review!(meters, consent_documents)
        redirect_to admin_school_meter_review_path(@school, review), notice: 'Review was successfully recorded. Meters will shortly be activated.'
      rescue => e
        redirect_to new_admin_school_meter_review_path(@school), alert: e.message
      end

      def show
      end

      private

      def meter_review_params
        params.require(:meter_review).permit(:meter_ids, :consent_document_ids, :school_id)
      end
    end
  end
end
