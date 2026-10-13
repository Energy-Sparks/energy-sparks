# frozen_string_literal: true

namespace :issues do
  task admin_meter_report: [:environment] do
    User.admin.active.operations.find_each do |user|
      IssuesReportMailer.admin_meter_report(user).deliver
    end
  end
end
