module Admin::Commercial
  class LicencesController < AdminController
    load_and_authorize_resource :licence, class: 'Commercial::Licence'

    def index
      @expiry_date = filter_params[:expiry_date]
      @last_month = filter_params[:last_month]
      @school_group_id = filter_params[:school_group_id]

      # FIXME filters.
      @expiring_licences = filter(:expiring, @expiry_date, @school_group_id)
      @recently_expired_licences = filter(:recently_expired, @last_month)
      @recent_licences = filter(:recent, @last_month)
      @recently_updated_licences = filter(:recently_updated, @last_month)
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

    def filter(scope, date, school_group_id = nil)
      scope = Commercial::Licence.public_send(scope, date)
      scope = scope.joins(school: :school_group).where(school_groups: { id: school_group_id }) if school_group_id
      scope.includes(:contract, :school, school: :school_group, contract: :product).by_start_date
    end

    def filter_params
      params.fetch(:filters, {}).with_defaults(
        expiry_date: (Time.zone.today + 1.month).end_of_month,
        last_month: (Time.zone.today - 1.month).beginning_of_month,
        school_group_id: nil
      )
    end

    def licence_params
      params.require(:licence).permit(
        :contract_id,
        :school_id,
        :invoice_reference,
        :end_date,
        :start_date,
        :status,
        :comments
      )
    end
  end
end
