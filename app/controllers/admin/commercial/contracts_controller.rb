# frozen_string_literal: true

module Admin
  module Commercial
    class ContractsController < AdminController # rubocop:disable Metrics/ClassLength
      ALLOWED_SCOPES = %w[current expired expiring future provisional recent].freeze
      CONTRACT_DEFAULTS = {
        'standard' => { licence_period: :contract, invoice_terms: :full },
        'pro-rata' => { licence_period: :contract, invoice_terms: :pro_rata },
        'custom' => { licence_period: :custom, invoice_terms: :full }
      }.freeze

      load_and_authorize_resource :contract, class: 'Commercial::Contract'

      def index
        @contracts = ::Commercial::Contract.all.by_start_date
      end

      def current = load_contracts(action_name)

      def expired = load_contracts(action_name)

      def expiring = load_contracts(action_name)

      def future = load_contracts(action_name)

      def overlapping
        @contracts = ::Commercial::Contract.overlapping.ordered_by_contract_holder_name
      end

      def provisional = load_contracts(action_name)

      def recent = load_contracts(action_name)

      def over_licensed
        @contracts = ::Commercial::Contract.over_licensed
      end

      def pending_invoicing
        @contracts = ::Commercial::Contract.pending_invoicing
      end

      def contract_holder_options
        records = case params[:contract_holder_type]
                  when 'School'      then School.active.order(:name)
                  when 'SchoolGroup' then SchoolGroup.order(:name)
                  when 'Funder'      then Funder.order(:name)
                  else []
                  end

        render json: records.map { |r| { id: r.id, name: r.name } }
      end

      def show
        @pricing = ::Commercial::ContractPriceCalculator.new(@contract)
        @overlapping_licences = ::Commercial::Licence.overlapping.where(contract_id: @contract.id)
      end

      def choose
        @chosen_params = {
          contract_holder_id: params[:contract_holder_id],
          contract_holder_type: params[:contract_holder_type]
        }
      end

      def renew
        @original = ::Commercial::Contract.find(params.expect(:original_contract_id))
        @chosen_params = {
          contract_holder_id: params[:contract_holder_id],
          contract_holder_type: params[:contract_holder_type],
          original_contract_id: params[:original_contract_id]
        }
      end

      def new
        if renewal_request?
          @original = ::Commercial::Contract.find(params.expect(:original_contract_id))
          @contract = ::Commercial::Contract.as_renewal(@original, chosen_type: params.expect(:chosen_type).to_sym)
        else
          redirect_to choose_admin_commercial_contracts_path and return if chosen_params[:chosen_type].blank?

          @contract = build_contract
        end
        @title = new_model_form_title
      end

      def edit; end

      def create # rubocop:disable Metrics/AbcSize
        @contract = ::Commercial::Contract.build(contract_params.merge(created_by: current_user))
        unless @contract.save
          @original = ::Commercial::Contract.find(params[:original_contract_id]) if params[:original_contract_id]
          render :new and return
        end

        if @contract.update_licences?
          renew_licences(@contract)
          redirect_to(admin_commercial_contract_path(@contract),
                      notice: 'Contract and provisional licences have been created')
        elsif @contract.contract_holder.is_a?(School)
          ::Commercial::LicenceManager.new(@contract.contract_holder).school_onboarded(@contract)
          redirect_to(admin_commercial_contract_path(@contract),
                      notice: 'Contract has been created and school licence added')
        else
          redirect_to(admin_commercial_contract_path(@contract), notice: 'Contract has been created')
        end
      end

      def update
        if @contract.update(contract_params.merge(updated_by: current_user))
          if @contract.cascade_updates_to_licences?
            ::Commercial::ContractManager.new(@contract, current_user).cascade_updates_to_licences
            redirect_to(admin_commercial_contract_path(@contract),
                        notice: 'Contract and licences have been updated')
          else
            redirect_to(admin_commercial_contract_path(@contract),
                        notice: 'Contract has been updated')
          end
        else
          render :edit
        end
      end

      def destroy
        if @contract.destroy
          redirect_back_or_to(admin_commercial_contracts_path, alert: 'Contract has been deleted')
        else
          redirect_back_or_to(admin_commercial_contracts_path, alert: @contract.errors.full_messages.to_sentence)
        end
      end

      def confirm
        if @contract.update(status: :confirmed)
          ::Commercial::ContractManager.new(@contract, current_user).cascade_updates_to_licences
          notice = 'Contract and licences have been confirmed'
        else
          notice = 'Unable to confirm contract'
        end
        redirect_back_or_to(admin_commercial_contract_path(@contract), notice:)
      end

      private

      def filter_params
        params.fetch(:filters, {})
      end

      def load_contracts(scope)
        raise ArgumentError unless ALLOWED_SCOPES.include?(scope)

        @date = filter_params[:date]
        @contracts = ::Commercial::Contract.filtered(scope, @date)
      end

      def new_model_form_title
        if renewal_request?
          'Create renewed contract'
        elsif contract_holder_request?
          "Create a new #{chosen_params[:chosen_type]} contract for #{@contract.contract_holder.name}"
        else
          "Create new #{chosen_params[:chosen_type]} contract"
        end
      end

      def build_contract
        contract = ::Commercial::Contract.new_with_defaults(CONTRACT_DEFAULTS[chosen_params[:chosen_type]])
        if contract_holder_request?
          contract.contract_holder = find_contract_holder
        else
          contract.contract_holder_type = 'Funder'
        end

        contract
      end

      def renewal_request?
        chosen_params[:original_contract_id].present?
      end

      def contract_holder_request?
        chosen_params[:contract_holder_id].present?
      end

      def find_contract_holder
        case params[:contract_holder_type]
        when 'School'      then School.find(params.expect(:contract_holder_id))
        when 'SchoolGroup' then SchoolGroup.find(params.expect(:contract_holder_id))
        when 'Funder'      then Funder.find(params.expect(:contract_holder_id))
        end
      end

      def renew_licences(contract)
        original_contract = ::Commercial::Contract.find(params.expect(:original_contract_id))
        ::Commercial::ContractManager.new(contract).renew_licences(original_contract)
      end

      def chosen_params
        params.permit(:contract_holder_type, :contract_holder_id, :original_contract_id, :chosen_type)
      end

      def contract_params
        params.expect(contract: %i[agreed_school_price comments contract_holder_id contract_holder_type
                                   end_date invoice_terms licence_period licence_years name
                                   number_of_schools product_id purchase_order_number
                                   update_licences start_date status xero_account_code_id])
      end
    end
  end
end
