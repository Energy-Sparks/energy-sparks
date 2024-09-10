# frozen_string_literal: true

class PupilDashboardLearnMoreComponent < DashboardLearnMoreComponent
  def initialize(school:, user:, id: nil, classes: '')
    super(school: school, user: user, audience: :pupil, id: id, classes: classes)
  end

  def data_enabled_class
    data_enabled? ? 'data-enabled' : 'data-disabled p-4'
  end
end
