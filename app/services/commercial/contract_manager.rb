# frozen_string_literal: true

module Commercial
  class ContractManager
    def initialize(contract, current_user = nil)
      @contract = contract
      @current_user = current_user
    end

    # Create new licences for this contract for all schools associated with
    # a previous contract
    def renew_licences(original_contract)
      Commercial::Contract.transaction do
        original_contract.licences.each do |licence|
          Commercial::LicenceManager.new(licence.school).contract_renewed(@contract, licence)
        end
      end
    end

    # Apply any relevant changes made to this contract to its licences
    # Should be called immediately after updating the contract.
    def cascade_updates_to_licences
      Commercial::Contract.transaction do
        update_licence_dates
        update_licence_statuses
      end
    end

    private

    def update_licence_dates
      licence_dates = Commercial::LicenceManager.licence_dates(
        @contract,
        base_date: @contract.start_date
      )

      # update dates for all licences except those that are invoiced
      @contract.licences.where.not(status: :invoiced).find_each do |licence|
        licence.update!(licence_dates.merge(updated_by_id: @current_user&.id))
      end
    end

    def update_licence_statuses
      # update status for those that have not already advanced
      @contract.licences.where.not(status: %i[pending_invoice invoiced]).find_each do |licence|
        licence.update!(status: @contract.status)
      end
    end
  end
end
