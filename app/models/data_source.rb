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
#  loa_contact_details         :text
#  loa_expiry_procedure        :text
#  name                        :string           not null
#  new_area_data_feed          :text
#  organisation_type           :integer
#  updated_at                  :datetime         not null
#
class DataSource < ApplicationRecord
  enum organisation_type: { energy_supplier: 0, procurement_organisation: 1, meter_operator: 2, council: 3, solar_monitoring_provider: 4 }
  validates :name, presence: true
end
