module Admin::Commercial
  class LicencesController < AdminController
    load_and_authorize_resource :licence, class: 'Commercial::Licence'

    def index
      @licences = Commercial::Licence.all
    end

    def new
      @licence = Commercial::Licence.new(contract_id: params[:contract_id])
    end

    def create
      @licence = Commercial::Licence.build(licence_params.merge(created_by: current_user))
      if @licence.save
        redirect_to admin_commercial_contract_path(@licence.contract), notice: 'Licence has been created'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @licence.update(licence_params.merge(updated_by: current_user))
        redirect_to admin_commercial_contract_path(@licence.contract), notice: 'Licence has been updated'
      else
        render :edit
      end
    end

    def destroy
      path = admin_commercial_contract_path(@licence.contract)
      if @licence.destroy
        redirect_to(path, alert: 'Licence has been deleted')
      else
        redirect_to(path, alert: @licence.errors.full_messages.to_sentence)
      end
    end

    private

    def licence_params
      params.require(:licence).permit(
        :contract_id,
        :school_id,
        :invoice_reference,
        :end_date,
        :start_date,
        :status
      )
    end
  end
end
