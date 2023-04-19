# == Schema Information
#
# Table name: procurement_routes
#
#  add_existing_data_feed      :text
#  comments                    :text
#  contact_email               :string
#  contact_name                :string
#  data_issues_contact_details :text
#  data_prerequisites          :text
#  id                          :bigint(8)        not null, primary key
#  loa_contact_details         :string
#  loa_expiry_procedure        :text
#  new_area_data_feed          :text
#  organisation_name           :string           not null
#
class ProcurementRoute < ApplicationRecord
end
