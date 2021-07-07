# == Schema Information
#
# Table name: rtone_variant_installations
#
#  amr_data_feed_config_id :bigint(8)        not null
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  password                :string
#  rtone_meter_id          :string
#  rtone_meter_type        :integer
#  school_id               :bigint(8)        not null
#  updated_at              :datetime         not null
#  username                :string
#
# Indexes
#
#  index_rtone_variant_installations_on_amr_data_feed_config_id  (amr_data_feed_config_id)
#  index_rtone_variant_installations_on_school_id                (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (amr_data_feed_config_id => amr_data_feed_configs.id)
#  fk_rails_...  (school_id => schools.id)
#
class RtoneVariantInstallation < ApplicationRecord
  belongs_to :school
  belongs_to :amr_data_feed_config
  belongs_to :meter

  enum rtone_meter_type: [:prod, :in1, :out1]

  validates_presence_of :school, :rtone_meter_id, :rtone_meter_type, :username, :password
  validates_uniqueness_of :rtone_meter_id, scope: :school
end
