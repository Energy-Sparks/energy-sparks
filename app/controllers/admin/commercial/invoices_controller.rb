# frozen_string_literal: true

module Admin
  module Commercial
    class InvoicesController < AdminController
      load_and_authorize_resource :invoice, class: 'Commercial::Invoice'

      def index
        @invoices = ::Commercial::Invoice.by_date
      end
    end
  end
end
