# == Schema Information
#
# Table name: alert_types
#
#  analysis_description :text
#  category             :integer
#  daily_frequency      :integer
#  id                   :bigint(8)        not null, primary key
#  long_term            :boolean
#  sample_message       :text
#  short_term           :boolean
#  sub_category         :integer
#  title                :text
#
FactoryBot.define do
  factory :alert_type do
    sequence(:title) {|n| "Alert Type #{n}"}
    category { AlertType.categories.keys.sample }
    sub_category { AlertType.sub_categories.keys.sample }
    frequency { AlertType.frequencies.keys.sample }
    class_name { 'AlertChangeInElectricityBaseloadShortTerm' }
  end
end
