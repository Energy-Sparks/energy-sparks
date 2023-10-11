module Admin
  class DashboardMessagesController < AdminController
    load_and_authorize_resource :school_group, instance_name: 'messageable'
    load_and_authorize_resource :school, instance_name: 'messageable'

    def edit
      @dashboard_message = @messageable.dashboard_message || @messageable.build_dashboard_message
    end

    def update
      @dashboard_message = @messageable.dashboard_message || @messageable.build_dashboard_message
      @dashboard_message.attributes = dashboard_message_params
      if @dashboard_message.save
        redirect_to params[:redirect_back], notice: "#{@messageable.model_name.human} dashboard message saved"
      else
        render :edit
      end
    end

    def destroy
      @dashboard_message = @messageable.dashboard_message
      @dashboard_message.destroy!
      redirect_to params[:redirect_back] || request.referer, notice: "#{@messageable.model_name.human} dashboard message removed"
    end

    private

    def dashboard_message_params
      params.require(:dashboard_message).permit(:message)
    end
  end
end
