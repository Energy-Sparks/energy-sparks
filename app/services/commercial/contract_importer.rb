module Commercial
  class ContractImporter
    def initialize(import_user: User.admin.first)
      @import_user = import_user
    end

    def import(data)
      unless data[:product_name].present? &&
             data[:contract_holder].present? &&
             data[:start_date].present? &&
             data[:end_date].present?
        return
      end

      product = Commercial::Product.find_by_name(data[:product_name])
      return if product.nil?

      contract_holder = contract_holder(data[:contract_holder])
      return if contract_holder.nil?

      contract = Commercial::Contract.find_or_initialize_by(
        product:,
        contract_holder:,
        start_date: Date.parse(data[:start_date]),
        end_date: Date.parse(data[:end_date])
      )
      contract.update!(
        name: data[:name],
        comments: "Imported on #{Time.zone.today}",
        status: :confirmed,
        agreed_school_price: data[:agreed_school_price].to_f,
        number_of_schools: 1,
        licence_period: data[:licence_period],
        invoice_terms: data[:invoice_terms] || 'pro_rata',
        licence_years: data[:licence_years],
        created_by: contract.created_by || @import_user,
        updated_by: @import_user
      )
      contract
    end

    private

    def contract_holder(name)
      contract_holder = Funder.find_by_name(name)
      return contract_holder unless contract_holder.nil?

      contract_holder = School.find_by_name(name)
      return contract_holder unless contract_holder.nil?

      return SchoolGroup.find_by_name(name)
    end
  end
end
