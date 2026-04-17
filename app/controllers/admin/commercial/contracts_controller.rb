# frozen_string_literal: true

module Admin
  module Commercial
    class ContractsController < AdminController
      load_and_authorize_resource :contract, class: 'Commercial::Contract'

      def index
        @contracts = ::Commercial::Contract.all.by_start_date
      end

      def current = load_contracts(action_name)

      def expired = load_contracts(action_name)

      def expiring = load_contracts(action_name)

      def recent = load_contracts(action_name)

      def contract_holder_options
        records = case params[:contract_holder_type]
                  when 'School'      then School.active.order(:name)
                  when 'SchoolGroup' then SchoolGroup.order(:name)
                  when 'Funder'      then Funder.order(:name)
                  else []
                  end

        render json: records.map { |r| { id: r.id, name: r.name } }
      end

      def new
        @contract = if renewal_request?
                      @original = ::Commercial::Contract.find(params[:original_contract_id])
                      ::Commercial::Contract.as_renewal(@original)
                    elsif contract_holder_request?
                      ::Commercial::Contract.new(contract_holder: find_contract_holder)
                    else
                      ::Commercial::Contract.new(contract_holder_type: 'Funder')
                    end
      end

      def edit; end

      def create
        @contract = ::Commercial::Contract.build(contract_params.merge(created_by: current_user))
        render :new and return unless @contract.save

        if params[:renew_licences] == '1'
          renew_licences(@contract)
          redirect_to(admin_commercial_contract_path(@contract),
                      notice: 'Contract and provisional licences have been created') # rubocop:disable Rails/I18nLocaleTexts
        else
          redirect_to(admin_commercial_contract_path(@contract), notice: 'Contract has been created') # rubocop:disable Rails/I18nLocaleTexts
        end
      end

      def update
        if @contract.update(contract_params.merge(updated_by: current_user))
          if @contract.cascade_updates_to_licences?
            ::Commercial::ContractManager.new(@contract, current_user).cascade_updates_to_licences
            redirect_to(admin_commercial_contract_path(@contract),
                        notice: 'Contract and licences have been updated') # rubocop:disable Rails/I18nLocaleTexts
          else
            redirect_to(admin_commercial_contract_path(@contract),
                        notice: 'Contract has been updated') # rubocop:disable Rails/I18nLocaleTexts
          end
        else
          render :edit
        end
      end

      def destroy
        if @contract.destroy
          redirect_to(admin_commercial_contracts_path, alert: 'Contract has been deleted') # rubocop:disable Rails/I18nLocaleTexts
        else
          redirect_to(admin_commercial_contracts_path, alert: @contract.errors.full_messages.to_sentence)
        end
      end

      private

      def load_contracts(scope)
        ::Commercial::Contract.send(scope).by_start_date
      end

      def renewal_request?
        params[:original_contract_id].present?
      end

      def contract_holder_request?
        params[:contract_holder_id].present?
      end

      def find_contract_holder
        case params[:contract_holder_type]
        when 'School'      then School.find(params[:contract_holder_id])
        when 'SchoolGroup' then SchoolGroup.find(params[:contract_holder_id])
        when 'Funder'      then Funder.find(params[:contract_holder_id])
        end
      end

      def renew_licences(contract)
        original_contract = ::Commercial::Contract.find(params[:original_contract_id])
        ::Commercial::ContractManager.new(contract).renew_licences(original_contract)
      end

      def contract_params
        params.require(:contract).permit(:agreed_school_price, :comments, :contract_holder_id, :contract_holder_type,
                                         :end_date, :invoice_terms, :licence_period, :licence_years, :name,
                                         :number_of_schools, :product_id, :purchase_order_number, :start_date, :status)
      end
    end
  end
end
