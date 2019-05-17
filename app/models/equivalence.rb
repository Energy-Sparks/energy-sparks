# == Schema Information
#
# Table name: equivalences
#
#  created_at                          :datetime         not null
#  data                                :json
#  equivalence_type_content_version_id :bigint(8)        not null
#  id                                  :bigint(8)        not null, primary key
#  school_id                           :bigint(8)        not null
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
end
