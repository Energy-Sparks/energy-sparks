# frozen_string_literal: true

class DashboardPromptComponent < PromptComponent
  def initialize(user:, **_kwargs)
    super
    @user = user
  end
end
