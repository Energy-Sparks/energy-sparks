module Admin
  class DashboardMessagesController < AdminController
    load_and_authorize_resource :school_group, instance_name: 'object'
    # This has been designed with the idea that schools will also be able
    # to have dashboard messages further down the line. Hopefully just adding
    # the following should make the controller support schools too:
    ## load_and_authorize_resource :school, instance_name: 'object'
    # A new route will be required for dashboard messages for schools too
    # Along with including the partial for a dashboard message in admin/schools#show

    def create
      @dashboard_message = @object.create_dashboard_message!(dashboard_message_params)
      redirect_to url_for([:admin, @object]), notice: "#{@object.model_name.human} dashboard message saved"
    end

    def edit
      @dashboard_message = @object.dashboard_message
    end

    def update
      @dashboard_message = @object.dashboard_message
      @dashboard_message.update!(dashboard_message_params)
      redirect_to url_for([:admin, @object]), notice: "#{@object.model_name.human} dashboard message saved"
    end

    def destroy
      @dashboard_message = @object.dashboard_message
      @dashboard_message.destroy
      redirect_to url_for([:admin, @object]), notice: "#{@object.model_name.human} dashboard message removed"
    end

  private

    def dashboard_message_params
      params.require(:dashboard_message).permit(:message)
    end
  end
end
