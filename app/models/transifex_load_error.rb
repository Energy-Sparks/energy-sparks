# == Schema Information
#
# Table name: transifex_load_errors
#
#  id                :bigint           not null, primary key
#  error             :string
#  record_type       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  record_id         :bigint
#  transifex_load_id :bigint           not null
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
  validates_presence_of :error
end
