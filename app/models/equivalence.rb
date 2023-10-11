# == Schema Information
#
# Table name: equivalences
#
#  created_at                          :datetime         not null
#  data                                :json
#  data_cy                             :json
#  equivalence_type_content_version_id :bigint(8)        not null
#  from_date                           :date
#  id                                  :bigint(8)        not null, primary key
#  relevant                            :boolean          default(TRUE)
#  school_id                           :bigint(8)        not null
#  to_date                             :date
#  updated_at                          :datetime         not null
#
# Indexes
#
#  index_equivalences_on_equivalence_type_content_version_id  (equivalence_type_content_version_id)
#  index_equivalences_on_school_id                            (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (equivalence_type_content_version_id => equivalence_type_content_versions.id) ON DELETE => cascade
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class Equivalence < ApplicationRecord
  belongs_to :school
  belongs_to :content_version, class_name: 'EquivalenceTypeContentVersion', foreign_key: :equivalence_type_content_version_id

  delegate :equivalence_type, to: :content_version

  def formatted_variables(locale = I18n.locale)
    variables(locale).each_with_object({}) do |(name, values), formatted|
      formatted[name] = values[:formatted_equivalence]
    end
  end

  def via_unit
    data_via_units.compact.join(' ')
  end

  def hide_preview?
    !relevant
  end

  private

  def data_via_units
    energy_conversion_units.map { |unit| data.dig(unit.to_s, 'via') }
  end

  def energy_conversion_units
    EnergyConversions.additional_frontend_only_variable_descriptions.map { |unit| unit.last[:via] }
  end

  def variables(locale)
    variables = if locale == :cy
                  data_cy&.any? ? data_cy : data
                else
                  data
                end
    variables.deep_transform_keys do |key|
      :"#{key.to_s.gsub('£', 'gbp')}"
    end
  end
end
