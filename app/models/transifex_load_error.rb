# == Schema Information
#
# Table name: transifex_load_errors
#
#  created_at        :datetime         not null
#  error             :string
#  id                :bigint(8)        not null, primary key
#  record_id         :bigint(8)
#  record_type       :string
#  transifex_load_id :bigint(8)        not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  transifex_load_error_run_idx  (transifex_load_id)
#
# Foreign Keys
#
#  fk_rails_...  (transifex_load_id => transifex_loads.id)
#
class TransifexLoadError < ApplicationRecord
  belongs_to :transifex_load
  validates :error, presence: true
end
