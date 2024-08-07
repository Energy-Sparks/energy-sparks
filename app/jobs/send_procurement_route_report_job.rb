class SendProcurementRouteReportJob < ApplicationJob
  queue_as :default

  def priority
    5
  end

  def perform(to:, procurement_route_id:)
    AdminMailer.with(to: to, procurement_route_id: procurement_route_id).school_procurement_route_report.deliver
  end
end
