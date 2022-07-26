# == Schema Information
#
# Table name: equivalence_type_content_versions
#
#  _equivalence        :text
#  created_at          :datetime         not null
#  equivalence_type_id :bigint(8)        not null
#  id                  :bigint(8)        not null, primary key
#  replaced_by_id      :bigint(8)
#  updated_at          :datetime         not null
#
# Indexes
#
#  eqtcv_eqtcv_repl                                                (replaced_by_id)
#  index_equivalence_type_content_versions_on_equivalence_type_id  (equivalence_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (equivalence_type_id => equivalence_types.id) ON DELETE => cascade
#  fk_rails_...  (replaced_by_id => equivalence_type_content_versions.id) ON DELETE => nullify
#

class EquivalenceTypeContentVersion < ApplicationRecord
  extend Mobility
  include TransifexSerialisable

  belongs_to :equivalence_type
  belongs_to :replaced_by, class_name: 'EquivalenceTypeContentVersion', foreign_key: :replaced_by_id, optional: true

  translates :equivalence, backend: :action_text

  scope :latest, -> { where(replaced_by_id: nil) }

  TX_ATTRIBUTE_MAPPING = {
    equivalence: { templated: true }
  }.freeze

  def self.template_fields
    [
      :equivalence,
    ]
  end

  def resource_key
    "#{self.class.model_name.i18n_key}_#{self.equivalence_type.id}"
  end

  def tx_name
    "#{self.class.model_name.i18n_key} #{equivalence_type.id}"
  end

  def tx_categories
    ['equivalences']
  end
end
