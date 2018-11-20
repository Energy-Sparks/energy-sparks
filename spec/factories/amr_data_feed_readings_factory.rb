FactoryBot.define do
  factory :amr_data_feed_reading do
    reading_date Date.yesterday
    readings { Array.new(48, rand) }
    meter
    mpan_mprn { Random.new.rand(240000000000000)}
  end
end


#  amr_data_feed_config_id     :bigint(8)
#  amr_data_feed_import_log_id :bigint(8)
#  created_at                  :datetime         not null
#  description                 :text
#  id                          :bigint(8)        not null, primary key
#  meter_id                    :bigint(8)
#  meter_serial_number         :text
#  mpan_mprn                   :text             not null
#  postcode                    :text
#  provider_record_id          :text
#  reading_date                :text             not null
#  readings                    :text             not null, is an Array
#  school                      :text
#  total                       :text
#  type                        :text
#  units                       :text
#  updated_at                  :datetime         not null
#
# Indexes