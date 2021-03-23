module Schools
  class BillRequestService
    def initialize(school)
      @school = school
    end

    def users
      users = @school.users.school_admin + @school.users.staff
      users.sort_by(&:staff_role)
    end

    def request_documentation!(users, meters = [])
      electricity_meters = meters.select {|m| m.meter_type.to_s == "electricity"}
      gas_meters = meters.select {|m| m.meter_type.to_s == "gas"}
      BillRequestMailer.with(emails: users.map(&:email), school: @school, electricity_meters: electricity_meters, gas_meters: gas_meters, subject: "Please upload a recent energy bill to Energy Sparks").request_bill.deliver_now
    end
  end
end
