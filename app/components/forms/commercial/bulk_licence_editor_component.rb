# frozen_string_literal: true

module Forms
  module Commercial
    class BulkLicenceEditorComponent < ApplicationComponent
      DEFAULT_FIELDS = %i[comments end_date invoice_reference school_specific_price start_date status].freeze

      def initialize(contract:, additional_schools: [], form_path: nil, exclude_fields: [], **kwargs)
        super
        @contract = contract
        @form_path = form_path
        @additional_schools = additional_schools
        @fields = DEFAULT_FIELDS - exclude_fields
      end

      def before_render
        view_context.content_for(:head) do
          helpers.javascript_import_module_tag('commercial/licence-toggle-delete')
        end
      end

      def self.licence_row(licence:, form:, exclude_fields: [])
        fields = DEFAULT_FIELDS - exclude_fields
        LicenceRowComponent.new(licence:, form:, fields:)
      end

      class LicenceRowComponent < ViewComponent::Base
        attr_reader :form, :licence

        def initialize(licence:, form:, fields: [])
          super()
          @licence = licence
          @form = form
          @fields = fields
        end

        def show_field?(name)
          @fields.include?(name)
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
