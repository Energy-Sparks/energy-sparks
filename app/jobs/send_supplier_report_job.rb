# frozen_string_literal: true

class SendSupplierReportJob < ApplicationJob
  queue_as :default

  def priority
    5
  end

  def perform(to:, supplier_id:)
    AdminMailer.with(to: to, supplier_id: supplier_id).school_supplier_report.deliver
  end
end
