class BillRequestMailerPreview < ActionMailer::Preview
  def request_bill
    BillRequestMailer.with(users: School.first.users, school: School.first, electricity_meters: [Meter.electricity.first], gas_meters: [Meter.gas.first]).request_bill
  end
  def notify_admin
    BillRequestMailer.with(school: School.first, consent_document: ConsentDocument.first, updated: false).notify_admin
  end
end
