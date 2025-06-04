# == Schema Information
#
# Table name: data_sources
#
#  add_existing_data_feed      :text
#  comments                    :text
#  contact_email               :string
#  contact_name                :string
#  created_at                  :datetime         not null
#  data_feed_type              :string
#  data_issues_contact_details :text
#  data_prerequisites          :text
#  historic_data               :text
#  id                          :bigint(8)        not null, primary key
#  import_warning_days         :integer
#  loa_contact_details         :text
#  loa_expiry_procedure        :text
#  load_tariffs                :boolean          default(TRUE), not null
#  name                        :string           not null
#  new_area_data_feed          :text
#  organisation_type           :integer
#  updated_at                  :datetime         not null
#
class DataSource < ApplicationRecord
  enum :organisation_type, { energy_supplier: 0, procurement_organisation: 1, meter_operator: 2, council: 3,
                             solar_monitoring_provider: 4 }
  validates :name, presence: true, uniqueness: true
  has_many :meters
  has_many :issues, as: :issueable, dependent: :destroy
  has_many :schools, -> { distinct }, through: :meters

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
