module Forms
  module Commercial
    class BulkLicenceEditorComponentPreview < ViewComponent::Preview
      # @param contract_id select :contract_options
      # @param hide_fields "Comma separated list of Licence model attributes"
      def example(contract_id: nil, hide_fields: '')
        contract = contract_id.nil? ? ::Commercial::Contract.all.sample : ::Commercial::Contract.find(contract_id)
        exclude_fields = hide_fields.present? ? hide_fields.split(',').map(&:strip).map(&:to_sym) : []
        render Forms::Commercial::BulkLicenceEditorComponent.new(contract:, form_path: '', exclude_fields:)
      end

      private

      def contract_options
        {
          choices: ::Commercial::Contract.by_name.map { |c| [c.name, c.id] }
        }
      end
    end
  end
end
