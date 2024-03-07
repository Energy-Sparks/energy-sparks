# == Schema Information
#
# Table name: annual_electricity_out_of_hours_uses
#
#  alert_generation_run_id                       :bigint(8)
#  community_gbp                                 :float
#  community_percent                             :float
#  electricity_economic_tariff_changed_this_year :boolean
#  holidays_percent                              :float
#  id                                            :bigint(8)
#  out_of_hours_gbp                              :float
#  potential_saving_gbp                          :float
#  school_id                                     :bigint(8)
#  schoolday_closed_percent                      :float
#  schoolday_open_percent                        :float
#  weekends_percent                              :float
#
class Comparison::AnnualElectricityOutOfHoursUse < Comparison::View
end
