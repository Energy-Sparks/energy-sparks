# == Schema Information
#
# Table name: procurement_routes
#
#  add_existing_data_feed      :text
#  comments                    :text
#  contact_email               :string
#  contact_name                :string
#  created_at                  :datetime         not null
#  data_issues_contact_details :text
#  data_prerequisites          :text
#  id                          :bigint(8)        not null, primary key
#  loa_contact_details         :string
#  loa_expiry_procedure        :text
#  new_area_data_feed          :text
#  organisation_name           :string           not null
#  updated_at                  :datetime         not null
#
class ProcurementRoute < ApplicationRecord
  validates :organisation_name, presence: true
  has_many :meters
  has_many :schools, -> { distinct }, through: :meters

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << csv_headers
      meters.each do |meter|
        csv << [
          meter&.school&.school_group&.name,
          meter&.school&.name,
          meter&.mpan_mprn,
          meter&.meter_type&.humanize,
          meter&.active,
          (meter.half_hourly ? 'Yes' : 'No'),
          meter&.first_validated_reading,
          meter&.last_validated_reading,
          meter&.admin_meter_status_label,
          meter&.data_source&.name,
          meter&.open_issues_count
        ] + meter&.open_issues_as_list
      end
    end
  end

  private

  def csv_headers
    ["School group", "School", "MPAN/MPRN", "Meter type", "Active", "Half-Hourly", "First validated meter reading", "Last validated meter reading", "Admin Meter Status", "Data Source", "Open issues count", "Open issues"]
  end
end
