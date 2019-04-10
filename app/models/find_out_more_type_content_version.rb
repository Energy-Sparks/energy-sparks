# == Schema Information
#
# Table name: find_out_more_type_content_versions
#
#  colour                :integer          default("red"), not null
#  created_at            :datetime         not null
#  dashboard_title       :string           not null
#  find_out_more_type_id :bigint(8)        not null
#  id                    :bigint(8)        not null, primary key
#  page_content          :text             not null
#  page_title            :string           not null
#  replaced_by_id        :integer
#  updated_at            :datetime         not null
#
# Indexes
#
#  fom_content_v_fom_id  (find_out_more_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (find_out_more_type_id => find_out_more_types.id) ON DELETE => cascade
#

class FindOutMoreTypeContentVersion < ApplicationRecord
  belongs_to :find_out_more_type
  belongs_to :replaced_by, class_name: 'FindOutMoreTypeContentVersion', foreign_key: :replaced_by_id

  enum colour: [:red, :yellow, :green]

  validates :dashboard_title, :page_title, :page_content, :colour, presence: true

  scope :latest, -> { where(replaced_by_id: nil) }

  def interpolated(field, variables)
    TemplateInterpolation.new(send(field)).interpolate(variables)
  end
end
