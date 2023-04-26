# == Schema Information
#
# Table name: intervention_type_groups
#
#  active      :boolean          default(TRUE)
#  created_at  :datetime         not null
#  description :string
#  icon        :string           default("question-circle")
#  id          :bigint(8)        not null, primary key
#  name        :string
#  updated_at  :datetime         not null
#
class InterventionTypeGroup < ApplicationRecord
  extend Mobility
  include TransifexSerialisable

  translates :name, type: :string, fallbacks: { cy: :en }
  translates :description, type: :string, fallbacks: { cy: :en }

  validates :name, presence: true, uniqueness: true

  has_many :intervention_types

  scope :by_name, -> { i18n.order(name: :asc) }
  scope :active,  -> { where(active: true) }

  #override default name for this resource in transifex
  def tx_name
    name
  end

  def self.listed_with_intervention_types
    all.order(:name).map {|group| [group, group.intervention_types.display_order.to_a]}
  end
end
