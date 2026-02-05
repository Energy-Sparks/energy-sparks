module Commercial
  # Creates, or updates the Commercial::Licence for a school based on the contract
  class LicenceManager
    def initialize(school)
      @school = school
    end

    def school_onboarded(contract)
      return unless contract

      case contract.licence_period
      when 'contract'
        start_date = contract.start_date
        end_date = contract.end_date
      else # custom
        # these dates will change later, when school is made data visible
        start_date = Time.zone.today
        end_date = add_years(start_date, contract.licence_years)
      end
      contract.licences.create(
        contract: contract,
        school: @school,
        start_date:,
        end_date:,
        status: contract.confirmed? ? :confirmed : :provisional
      )
    end

    def school_made_data_enabled
      licence = @school.licences.current.first
      return unless licence

      if licence.contract.licence_period.to_sym == :custom
        licence.start_date = Time.zone.today
        licence.end_date = add_years(licence.start_date, licence.contract.licence_years)
      end
      licence.status = :pending_invoice unless licence.status.to_sym != :confirmed
      licence.save
      licence
    end

    private

    # Take licence years, which is a float specifying length of licence, e.g. 1.0, 2.0, 1.75 (1 yr, 9 months)
    # and add to a start date
    def add_years(start_date, licence_years)
      start_date + (licence_years * 12).round.months
    end
  end
end
