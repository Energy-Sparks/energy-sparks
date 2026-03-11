module Forms
  module Commercial
    class BulkLicenceEditorComponent < ApplicationComponent
      # FIXME: specify fields to include, e.g. creating contract/renewal vs invoicing
      # FIXME: specify whether to allow adding extra schools
      # FIXME: specify path for adding extra schools?
      # FIXME: bulk edit options? invoice ref, status, add all missing
      def initialize(contract:, form_path: nil, **kwargs)
        super
        @contract = contract
        @form_path = form_path
      end

      def form_path
        @form_path || admin_commercial_contract_licences_path(@contract)
      end

      def licences
        @contract.licences.current.joins(:school).order(school: { name: :asc })
      end
    end
  end
end
