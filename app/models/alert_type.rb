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
class AlertType < ApplicationRecord
  has_many :alerts

  enum category: [:electricity, :gas]
  enum sub_category: [:hot_water, :heating, :frost_protection, :optimum_start, :heating_turn_on_off, :heating_off, :change_in_consumption, :change_in_baseload_consumption, :baseload]
end
