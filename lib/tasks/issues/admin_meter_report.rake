# frozen_string_literal: true

namespace :issues do
  desc 'Issues report'
  task admin_meter_report: [:environment] do
    User.where(operations: true).find_each do |user|
      IssuesReportMailer.admin_meter_report(user).deliver
    end
  end
end
