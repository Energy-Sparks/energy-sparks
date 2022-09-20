# == Schema Information
#
# Table name: case_studies
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  position   :integer          default(0), not null
#  title      :string
#  updated_at :datetime         not null
#
class CaseStudy < ApplicationRecord
  extend Mobility
  include TransifexSerialisable
  include TranslatableAttachment

  translates :title, type: :string, fallbacks: { cy: :en }
  translates :description, backend: :action_text

  t_has_one_attached :file

  validates :title, :file_en, presence: true
  validates :position, numericality: true, presence: true
end
