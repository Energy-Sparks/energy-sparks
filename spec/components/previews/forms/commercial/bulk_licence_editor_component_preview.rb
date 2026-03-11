module Forms
  module Commercial
    class BulkLicenceEditorComponentPreview < ViewComponent::Preview
      # @param contract_id select :contract_options
      def example(contract_id: nil)
        contract = contract_id.nil? ? ::Commercial::Contract.all.sample : ::Commercial::Contract.find(contract_id)
        render Forms::Commercial::BulkLicenceEditorComponent.new(contract:)
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
