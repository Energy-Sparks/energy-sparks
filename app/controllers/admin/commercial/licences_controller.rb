module Admin::Commercial
  class LicencesController < AdminController
    load_and_authorize_resource :licence, class: 'Commercial::Licence'

    def index
      @expiry_date = filter_params[:expiry_date]
      @expired_date = filter_params[:expired_date]
      @recently_added_date = filter_params[:recently_added_date]
      @recently_updated_date = filter_params[:recently_updated_date]

      @school_group_id = filter_params[:school_group_id]
      @tab = filter_params[:tab]

      @expiring_licences = Commercial::Licence.filtered(:expiring, @expiry_date, @school_group_id)
      @recently_expired_licences = Commercial::Licence.filtered(:recently_expired, @expired_date, @school_group_id)
      @recent_licences = Commercial::Licence.filtered(:recent, @recently_added_date, @school_group_id)
      @recently_updated_licences = Commercial::Licence.filtered(:recently_updated, @recently_updated_date, @school_group_id)
    end

    def new
      if params[:contract_id]
        @contract = Commercial::Contract.find(params[:contract_id])
        @licence = Commercial::Licence.new(contract: @contract)
      else
        @licence = Commercial::Licence.new
      end
    end

    def create
      @licence = Commercial::Licence.build(licence_params.merge(created_by: current_user))
      if @licence.start_date.nil? && @licence.end_date.nil?
        @licence.assign_attributes(
          Commercial::LicenceManager.new(@licence.school).licence_dates(@licence.contract)
        )
      end
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

    def filter_params
      last_month = (Time.zone.today - 1.month).beginning_of_month
      params.fetch(:filters, {}).with_defaults(
        expiry_date: (Time.zone.today + 1.month).end_of_month,
        expired_date: last_month,
        recently_added_date: last_month,
        recently_updated_date: last_month,
        school_group_id: nil,
        tab: 'expiring'
      )
    end

    def licence_params
      params.require(:licence).permit(
        :comments,
        :contract_id,
        :end_date,
        :invoice_reference,
        :school_id,
        :school_specific_price,
        :start_date,
        :status
      )
    end
  end
end
