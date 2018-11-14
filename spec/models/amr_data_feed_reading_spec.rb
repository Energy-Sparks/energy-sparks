# == Schema Information
#
# Table name: amr_data_feed_readings
#
#  id                      :bigint(8)        not null, primary key
#  amr_data_feed_config_id :integer          not null
#  meter_id                :integer
#  mpan_mprn               :bigint(8)        not null
#  reading_date            :date             not null
#  readings                :decimal(, )      not null, is an Array
#  postcode                :text
#  school                  :text
#  description             :text
#  units                   :text
#  total                   :decimal(, )
#  meter_serial_number     :text
#  provider_record_id      :text
#  type                    :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'rails_helper'

describe AmrDataFeedReading do


end
