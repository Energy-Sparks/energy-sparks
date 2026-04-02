# frozen_string_literal: true

FactoryBot.define do
  factory :impact_report_run, class: 'ImpactReport::Run' do
    school_group
    run_date { Time.zone.today }
  end
end
