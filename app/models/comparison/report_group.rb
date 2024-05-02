# == Schema Information
#
# Table name: comparison_report_groups
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  position   :integer          default(0), not null
#  updated_at :datetime         not null
#
class Comparison::ReportGroup < ApplicationRecord
  self.table_name = 'comparison_report_groups'

  extend Mobility
  include TransifexSerialisable

  has_many :reports, class_name: 'Comparison::Report'

  translates :title, type: :string, fallbacks: { cy: :en }
  translates :description, backend: :action_text

  validates :title, presence: true
  validates :position, numericality: true, presence: true
end
