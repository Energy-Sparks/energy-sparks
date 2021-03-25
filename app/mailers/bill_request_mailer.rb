class BillRequestMailer < ApplicationMailer
  def request_bill
    @school = params[:school]
    @electricity_meters = params[:electricity_meters]
    @gas_meters = params[:gas_meters]
    make_bootstrap_mail(to: params[:emails], subject: params[:subject])
  end
end
