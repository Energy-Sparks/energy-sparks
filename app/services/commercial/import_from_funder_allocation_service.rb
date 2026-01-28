module Commercial
  class ImportFromFunderAllocationService
    IGNORED_FUNDER_NAMES = ['Archive', 'Pending data', 'Pitched school self funding', 'Waiting list for funding'].freeze

    attr_reader :product, :import_user
    def initialize(product: Commercial::Product.default_product, import_user: User.admin.first)
      @product = product
      @import_user = import_user
    end

    # FIXME other columns
    #
    # Dates for Contracts and Licences
    # Contract details?
    # Licence details?
    def import(funder_name, school_name)
      school = School.find_by(name: school_name)
      return unless school

      # Skip inactive schools, to avoid adding C&L for archived/deleted?
      # Might be issues with funder association if we do
      # next unless school.active

      funder = Funder.find_by(name: funder_name)

      case funder_name
      when '', nil
        # this ensures consistency but might not want to change if the data is out of date?
        school.update!(funder: nil)
        return
      when *IGNORED_FUNDER_NAMES
        school.update!(funder: funder) if funder
        return
      when 'School self funding'
        contract_holder = school
        # Placeholder dates
        add_contract_and_licence(contract_holder:, school:, update_counts: false)
      when 'MAT funding'
        contract_holder = school.organisation_group
        add_contract_and_licence(contract_holder:, school:)
      else
        contract_holder = funder
        add_contract_and_licence(contract_holder:, school:) if funder
      end

      # FIXME, this ensures consistency but might not want to change if the data is out of date?
      default_contract_holder = case contract_holder
                                when Funder, SchoolGroup
                                  school.organisation_group
                                else
                                  school
                                end

      school.update!(funder:, default_contract_holder:) if funder
    end

    private

    def add_contract_and_licence(contract_holder:, school:, update_counts: true)
      contract = create_or_update_contract(
        contract_holder:,
        start_date: Date.new(2025, 9, 1), # Placeholder
        end_date: Date.new(2026, 8, 31)) # Placeholder
      create_or_update_licence(contract:,
                               school:,
                               start_date: contract.start_date, # Placeholder
                               end_date: contract.end_date)
      # FIXME only required if we don't have contract details
      # FIXME if we have licence dates, may need to vary start/end by those dates
      contract.update(number_of_schools: contract.licences.current.count) if update_counts
    end

    def create_or_update_contract(contract_holder:,
                                  start_date:,
                                  end_date:,
                                  status: 'confirmed',
                                  agreed_school_price: nil,
                                  number_of_schools: 1)
      contract = Commercial::Contract.find_or_initialize_by(
        product: @product,
        contract_holder:,
        start_date:,
        end_date:
      )
      contract.update(
        name: "#{contract_holder.name} #{start_date.year}-#{end_date.year}",
        comments: "Imported on #{Time.zone.today}",
        status:,
        agreed_school_price:,
        number_of_schools:,
        created_by: contract.created_by || @import_user,
        updated_by: @import_user
      )
      contract
    end

    def create_or_update_licence(contract:,
                                 school:,
                                 start_date:,
                                 end_date:,
                                 status: 'confirmed')
      licence = Commercial::Licence.find_or_initialize_by(
        contract:,
        school:,
        start_date:,
        end_date:
      )
      licence.update(status: status,
                     created_by: licence.created_by || @import_user,
                     updated_by: @import_user)
      licence
    end
  end
end
