module Forms
  module Commercial
    class BulkLicenceEditorComponent < ApplicationComponent
      DEFAULT_FIELDS = [:comments, :end_date, :invoice_reference, :school_specific_price, :start_date, :status].freeze

      # FIXME: specify whether to allow adding extra schools
      # FIXME: specify path for adding extra schools?
      # FIXME: bulk edit options? invoice ref, status, add all missing
      def initialize(contract:, form_path: nil, fields: DEFAULT_FIELDS, exclude_fields: [], **kwargs)
        super
        @contract = contract
        @form_path = form_path
        @fields = fields - exclude_fields
      end

      private

      def form_path
        @form_path || admin_commercial_contract_licences_path(@contract)
      end

      def licences
        @contract.licences.current.joins(:school).order(school: { name: :asc })
      end

      def show_field?(name)
        @fields.include?(name)
      end
    end
  end
end
