class FunderAllocationReportJob < ApplicationJob
  queue_as :default

  def priority
    10
  end

  def perform(to:)
    funder_report = Schools::FunderAllocationReportService.new
    AdminMailer.with(to: to, funder_report: funder_report).funder_allocation_report.deliver
  end
end
