# == Schema Information
#
# Table name: data_sources
#
#  add_existing_data_feed      :text
#  alert_percentage_threshold  :integer          default(25)
#  alerts_on                   :boolean          default(TRUE)
#  comments                    :text
#  contact_email               :string
#  contact_name                :string
#  created_at                  :datetime         not null
#  data_feed_type              :string
#  data_issues_contact_details :text
#  data_prerequisites          :text
#  historic_data               :text
#  id                          :bigint(8)        not null, primary key
#  import_warning_days         :integer          default(7)
#  loa_contact_details         :text
#  loa_expiry_procedure        :text
#  load_tariffs                :boolean          default(TRUE), not null
#  name                        :string           not null
#  new_area_data_feed          :text
#  organisation_type           :integer
#  owned_by_id                 :bigint(8)
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_data_sources_on_owned_by_id  (owned_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (owned_by_id => users.id)
#
class DataSource < ApplicationRecord
  enum :organisation_type, { energy_supplier: 0, procurement_organisation: 1, meter_operator: 2, council: 3,
                             solar_monitoring_provider: 4 }

  belongs_to :owned_by, class_name: :User, optional: true

  validates :alert_percentage_threshold, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_blank: true }
  validates :name, presence: true, uniqueness: true
  has_many :meters
  has_many :issues, as: :issueable, dependent: :destroy
  has_many :schools, -> { distinct }, through: :meters

  def percentage_of_lagging_meters
    active = meters.active_for_active_schools
    if active = 0
      0
    else
      meters.with_stale_readings / active * 100
    end
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << csv_headers
      meters.from_active_schools.order(:created_at).each do |meter|
        csv << ([
          meter&.school&.school_group&.name,
          meter&.school&.school_group&.default_issues_admin_user&.name,
          meter&.school&.name,
          meter&.mpan_mprn,
          meter&.meter_type&.humanize,
          meter&.active,
          meter.t_meter_system,
          meter&.first_validated_reading,
          meter&.last_validated_reading,
          meter&.admin_meter_status_label,
          meter&.open_issues_count
        ] + meter&.open_issues_as_list)
      end
    end
  end

  private

  def csv_headers
    ['School group', 'Admin', 'School', 'MPAN/MPRN', 'Meter type', 'Active', 'Half-Hourly', 'First validated meter reading',
     'Last validated meter reading', 'Admin Meter Status', 'Open issues count', 'Open issues']
  end
end
