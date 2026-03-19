module Forms
  module Commercial
    class BulkLicenceEditorComponent < ApplicationComponent
      DEFAULT_FIELDS = [:comments, :end_date, :invoice_reference, :school_specific_price, :start_date, :status].freeze

      def initialize(contract:, form_path: nil, fields: DEFAULT_FIELDS, exclude_fields: [], **kwargs)
        super
        @contract = contract
        @form_path = form_path
        @fields = fields - exclude_fields
      end

      def before_render
        view_context.content_for(:head) do
          helpers.javascript_import_module_tag('commercial/licence-toggle-delete')
        end
      end

      private

      def form_path
        @form_path || admin_commercial_contract_licences_path(@contract)
      end

      def licences
        @contract.licences.joins(:school).order(school: { name: :asc })
      end

      def show_field?(name)
        @fields.include?(name)
      end
    end
  end
end
