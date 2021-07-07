# == Schema Information
#
# Table name: rtone_variant_installations
#
#  amr_data_feed_config_id :bigint(8)        not null
#  configuration           :json
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  meter_id                :bigint(8)        not null
#  password                :string
#  rtone_component_type    :integer
#  rtone_meter_id          :string
#  school_id               :bigint(8)        not null
#  updated_at              :datetime         not null
#  username                :string
#
# Indexes
#
#  index_rtone_variant_installations_on_amr_data_feed_config_id  (amr_data_feed_config_id)
#  index_rtone_variant_installations_on_meter_id                 (meter_id)
#  index_rtone_variant_installations_on_school_id                (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (amr_data_feed_config_id => amr_data_feed_configs.id)
#  fk_rails_...  (meter_id => meters.id)
#  fk_rails_...  (school_id => schools.id)
#
class RtoneVariantInstallation < ApplicationRecord
  belongs_to :school
  belongs_to :amr_data_feed_config
  belongs_to :meter

  enum rtone_component_type: [:prod, :in1, :out1, :in2]

  validates_presence_of :school, :meter, :rtone_meter_id, :rtone_component_type, :username, :password
  validates_uniqueness_of :rtone_meter_id, scope: :school

  def latest_electricity_reading
    if meter.amr_data_feed_readings.any
      Date.parse(meter.amr_data_feed_readings.order(reading_date: :desc).first.reading_date)
    end
  end
end
