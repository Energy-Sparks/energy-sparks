module Admin
  class ProcurementRoutesController < AdminController
    load_and_authorize_resource

    def create
      if @procurement_route.save
        redirect_to admin_procurement_routes_path, notice: 'Procurement route was successfully created.'
      else
        render :new
      end
    end

    def update
      if @procurement_route.update(procurement_route_params)
        redirect_to admin_procurement_route_path(@procurement_route), notice: 'Procurement route was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @procurement_route.destroy
      redirect_to admin_procurement_routes_path, notice: 'Procurement route was successfully deleted.'
    end

    def deliver
      @procurement_route = ProcurementRoute.find(params[:procurement_route_id])
      SendProcurementRouteReportJob.perform_later(to: current_user.email, procurement_route_id: @procurement_route.id)
      redirect_back fallback_location: admin_procurement_route_path(@procurement_route), notice: "Procurement route report for #{@procurement_route.organisation_name} requested to be sent to #{current_user.email}"
    end

    private

    def procurement_route_params
      params.require(:procurement_route).permit(:organisation_name,
                                                :contact_name,
                                                :contact_email,
                                                :loa_contact_details,
                                                :data_prerequisites,
                                                :new_area_data_feed,
                                                :add_existing_data_feed,
                                                :data_issues_contact_details,
                                                :loa_expiry_procedure,
                                                :comments
                                               )
    end
  end
end
