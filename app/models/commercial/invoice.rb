# frozen_string_literal: true

module Commercial
  class Invoice < ApplicationRecord
    self.table_name = 'commercial_invoices'
  end
end
