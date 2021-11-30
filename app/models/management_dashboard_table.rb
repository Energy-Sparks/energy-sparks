# == Schema Information
#
# Table name: management_dashboard_tables
#
#  alert_id                             :bigint(8)
#  alert_type_rating_content_version_id :bigint(8)
#  content_generation_run_id            :bigint(8)
#  created_at                           :datetime         not null
#  id                                   :bigint(8)        not null, primary key
#  updated_at                           :datetime         not null
#
# Indexes
#
#  index_management_dashboard_tables_on_alert_id                   (alert_id)
#  index_management_dashboard_tables_on_content_generation_run_id  (content_generation_run_id)
#  man_dash_alert_content_version_index                            (alert_type_rating_content_version_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_id => alerts.id) ON DELETE => cascade
#  fk_rails_...  (alert_type_rating_content_version_id => alert_type_rating_content_versions.id) ON DELETE => restrict
#  fk_rails_...  (content_generation_run_id => content_generation_runs.id) ON DELETE => cascade
#

class ManagementDashboardTable < ApplicationRecord
  belongs_to :content_generation_run
  belongs_to :alert
  belongs_to :content_version, class_name: 'AlertTypeRatingContentVersion', foreign_key: :alert_type_rating_content_version_id

  def table
    alert.table_data['summary_table']
  end

  def data
    # eval(alert.template_data['summary_data'])
    dummy_data
  end

  private

  # TODO remove, obv.
  def dummy_data
    {
      :electricity => {
        :start_date => '2016-10-01',
        :end_date => '2021-11-01',
        :year => {
          :kwh => 108_827.5394000001,
          :co2 => 21_333.057423499995,
          :£ => 16_324.130910000014,
          :savings_£ => 967.8809100000144,
          :percent_change => 0.11050720181070751
        },
        :workweek => {
          # :recent => "No recent data",
          :recent => "",
          :kwh => 1205.2192,
          :co2 => 150.84771050000003,
          :£ => 180.78288,
          :savings_£ => "-",
          :percent_change => "-"
        }
      },
      :gas => {
        :start_date => '2021-04-13',
        :end_date => '2021-10-28',
        :year => {
          :available_from => "Data available from Apr 2022"
        },
        :workweek => {
          :recent => "No recent data",
          :kwh => 4930.7751,
          :co2 => 1035.462771,
          :£ => 147.923253,
          :savings_£ => "-",
          :percent_change => "-"
        }
      }
    }
  end
end
