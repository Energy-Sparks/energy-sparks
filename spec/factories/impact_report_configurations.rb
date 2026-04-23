# frozen_string_literal: true

FactoryBot.define do
  factory :impact_report_configuration, class: 'ImpactReport::Configuration' do
    school_group
    show_engagement { true }
  end
end
