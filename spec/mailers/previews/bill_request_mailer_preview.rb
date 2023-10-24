class BillRequestMailerPreview < ActionMailer::Preview
  def request_bill
    locale = @params["locale"].present? ? @params["locale"] : "en"
    BillRequestMailer.with(users: School.first.users, school: School.first, electricity_meters: [Meter.electricity.first], gas_meters: [Meter.gas.first], locale: locale).request_bill
  end

  def notify_admin
    BillRequestMailer.with(school: School.first, consent_document: ConsentDocument.first, updated: false).notify_admin
  end
end
