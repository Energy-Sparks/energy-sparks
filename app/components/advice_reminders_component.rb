class AdviceRemindersComponent < DashboardRemindersComponent
  include SchoolProgress

  attr_reader :alert_count, :priority_count

  def initialize(school:, user:, id: nil, classes: '')
    super(school: school, user: user, id: id, classes: classes)
    @alert_count = school.latest_adult_dashboard_alert_count
    @priority_count = school.latest_management_priority_count
  end
end
