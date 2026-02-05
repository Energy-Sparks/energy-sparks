module Commercial
  class LicenceImporter
    def initialize(import_user: User.admin.first)
      @import_user = import_user
    end

    def import(data)
      # FIXME missing dates
      unless data[:contract_name].present? &&
             data[:licence_holder].present? &&
             data[:start_date].present? &&
             data[:end_date].present?
        return
      end

      contract = Commercial::Contract.find_by_name(data[:contract_name])
      return if contract.nil?

      school = School.find_by_name(data[:licence_holder])
      return if school.nil?

      licence = Commercial::Licence.find_or_initialize_by(
        contract:,
        school:,
        start_date: Date.parse(data[:start_date]),
        end_date: Date.parse(data[:end_date])
      )
      licence.update!(
        comments: data[:comments],
        status: data[:status],
        school_specific_price: data[:school_specific_price],
        created_by: licence.created_by || @import_user,
        updated_by: @import_user
      )
      licence
    end
  end
end
