# == Schema Information
#
# Table name: simulators
#
#  configuration :json
#  id            :bigint(8)        not null, primary key
#  school_id     :bigint(8)
#  user_id       :bigint(8)
#
# Indexes
#
#  index_simulators_on_school_id  (school_id)
#  index_simulators_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#  fk_rails_...  (user_id => users.id)
#

class Simulator < ApplicationRecord
  belongs_to :school
  belongs_to :user


  def get_config_as_nested_hash
    hash_config = configuration.deep_symbolize_keys
    hash_config.each do |key, _value|
      nested = hash_config[key]

      nested[:editable] = nested[:editable].map(&:to_sym) if nested.key?(:editable)
      nested[:heating_season_start_dates] = nested[:heating_season_start_dates].map { |entry| Date.parse(entry) } if nested.key?(:heating_season_start_dates)
      nested[:heating_season_end_dates] = nested[:heating_season_end_dates].map { |entry| Date.parse(entry) } if nested.key?(:heating_season_end_dates)
      nested[:start_time] = Time.parse.utc(nested[:start_time]) if nested.key?(:start_time)
      nested[:end_time] = Time.parse.utc(nested[:end_time]) if nested.key?(:end_time)
    end
    hash_config
  end
end
