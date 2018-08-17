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
  factory :alert do
    alert_type
    class_name { 'AlertChangeInElectricityBaseloadShortTerm' }
  end
end
