class AdviceRemindersComponent < DashboardRemindersComponent
  include SchoolProgress

  attr_reader :alert_count, :priority_count

  def initialize(school:, alert_count:, priority_count:, user:, id: nil, classes: '')
    super(school: school, user: user, id: id, classes: classes)
    @alert_count = alert_count
    @priority_count = priority_count
  end
end
