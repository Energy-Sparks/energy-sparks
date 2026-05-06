module Commercial
  # Creates, or updates the Commercial::Licence for a school based on the contract
  class LicenceManager
    def initialize(school)
      @school = school
    end

    def self.licence_dates(contract, base_date: Time.zone.today)
      case contract.licence_period
      when 'contract'
        start_date = contract.start_date
        end_date = contract.end_date
      else # custom
        start_date = base_date
        end_date = add_years(base_date, contract.licence_years)
      end
      { start_date:, end_date: }
    end

    # Take licence years, which is a float specifying length of licence, e.g. 1.0, 2.0, 1.75 (1 yr, 9 months)
    # and add to a start date.
    #
    # The date ranges are specified as exclusive end dates, so subtract a day
    def self.add_years(start_date, licence_years)
      years = licence_years.floor
      months = ((licence_years - years) * 12).round
      # Advance by whole years and months
      end_date = start_date.advance(years: years, months: months)
      # Inclusive range: subtract 1 day
      end_date - 1.day
    end

    def school_onboarded(contract)
      create_licence(contract)
    end

    def school_made_data_enabled
      licence = @school.licences.current.first
      return unless licence

      if licence.contract.licence_period.to_sym == :custom
        licence_dates = self.class.licence_dates(licence.contract)
        licence.start_date = licence_dates[:start_date]
        licence.end_date = licence_dates[:end_date]
      end
      licence.status = :pending_invoice unless licence.status.to_sym != :confirmed
      licence.save
      licence
    end

    # Create a new licence for the school under a renewed contract, copying over any
    # school specific pricing from an original
    def contract_renewed(contract, original_licence)
      create_licence(contract,
                     base_date: contract.start_date,
                     school_specific_price: original_licence.school_specific_price,
                     comments: original_licence.comments)
    end

    private

    def create_licence(contract, base_date: Time.zone.today, school_specific_price: nil, comments: nil)
      return unless contract

      # these dates may change later, when school is made data visible
      licence_dates = self.class.licence_dates(contract, base_date:)

      contract.licences.create(
        contract: contract,
        school: @school,
        start_date: licence_dates[:start_date],
        end_date: licence_dates[:end_date],
        school_specific_price:,
        comments:,
        status: contract.confirmed? ? :confirmed : :provisional
      )
    end
  end
end
