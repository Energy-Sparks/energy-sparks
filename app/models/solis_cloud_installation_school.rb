# == Schema Information
#
# Table name: solis_cloud_installation_schools
#
#  created_at                  :datetime         not null
#  id                          :bigint(8)        not null, primary key
#  school_id                   :bigint(8)        not null
#  solis_cloud_installation_id :bigint(8)        not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  idx_on_solis_cloud_installation_id_c29f887970        (solis_cloud_installation_id)
#  index_solis_cloud_installation_schools_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#  fk_rails_...  (solis_cloud_installation_id => solis_cloud_installations.id)
#
class SolisCloudInstallationSchool < ApplicationRecord
  belongs_to :school
  belongs_to :solis_cloud_installation
end
