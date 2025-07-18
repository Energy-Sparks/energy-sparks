class FunderAllocationReportJob < ApplicationJob
  queue_as :default

  def priority
    5
  end

  def perform(to:)
    funder_report = Schools::FunderAllocationReportService.new
    Rails.root.join('tmp', funder_report.csv_filename).write(funder_report.csv) if Rails.env.development?
    AdminMailer.with(to:, funder_report:).funder_allocation_report.deliver
  end
end
