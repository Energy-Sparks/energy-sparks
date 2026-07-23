module Admin::Commercial
  class LicencesController < AdminController
    ALLOWED_SCOPES = %w[current expired expiring recent].freeze

    load_and_authorize_resource :licence, class: 'Commercial::Licence'

    def index
      @licences = Commercial::Licence.all.by_start_date
    end

    def current = load_licences(action_name)

    def expired = load_licences(action_name)

    def expiring = load_licences(action_name)

    def recent = load_licences(action_name)

    def unlicensed
      @schools = School.active.without_current_licence.joins(
        organisation_school_grouping: :school_group
      ).order('school_groups.name ASC')
    end

    def overlapping
      @licences = Commercial::Licence.overlapping.by_start_date
    end

    def new
      if params[:contract_id]
        @contract = Commercial::Contract.find(params[:contract_id])
        @schools = @contract.candidate_schools
        @licence = Commercial::Licence.new(contract: @contract)
      else
        @licence = Commercial::Licence.new
        @schools = School.visible.by_name
      end
    end

    def edit
    end

    def create # rubocop:disable Metrics/AbcSize
      @licence = Commercial::Licence.build(licence_params.merge(created_by: current_user))
      if @licence.start_date.nil? && @licence.end_date.nil?
        @licence.assign_attributes(
          Commercial::LicenceManager.licence_dates(@licence.contract)
        )
      end
      if @licence.save
        redirect_to admin_commercial_contract_path(@licence.contract), redirect_flash(@licence, 'created')
      else
        render :new
      end
    end

    def update
      if @licence.update(licence_params.merge(updated_by: current_user))
        redirect_to admin_commercial_contract_path(@licence.contract), redirect_flash(@licence, 'updated')
      else
        render :edit
      end
    end

    def destroy
      path = admin_commercial_contract_path(@licence.contract)
      if @licence.destroy
        redirect_back_or_to(path, alert: 'Licence has been deleted')
      else
        redirect_back_or_to(path, alert: @licence.errors.full_messages.to_sentence)
      end
    end

    private

    def filter_params
      params.fetch(:filters, {})
    end

    def redirect_flash(licence, action)
      if Commercial::Licence.overlapping.where(school_id: licence.school_id).any?
        { alert: "Licence has been #{action}. But this school now has overlapping licences" }
      else
        { notice: "Licence has been #{action}" }
      end
    end

    def load_licences(scope)
      raise ArgumentError unless ALLOWED_SCOPES.include?(scope)

      @date = filter_params[:date]
      @school_group_id = filter_params[:school_group_id]
      @licences = ::Commercial::Licence.filtered(scope, @date, @school_group_id)
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
