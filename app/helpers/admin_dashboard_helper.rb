# frozen_string_literal: true

module AdminDashboardHelper
  def prompt_cache_timestamp(user)
    user.owned_issues.maximum(:updated_at).to_i
  end
end
