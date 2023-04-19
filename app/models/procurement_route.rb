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
end
