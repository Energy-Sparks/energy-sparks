# == Schema Information
#
# Table name: intervention_types
#
#  active                     :boolean          default(TRUE)
#  created_at                 :datetime         not null
#  custom                     :boolean          default(FALSE)
#  fuel_type                  :string           default([]), is an Array
#  id                         :bigint(8)        not null, primary key
#  intervention_type_group_id :bigint(8)        not null
#  name                       :string
#  score                      :integer
#  show_on_charts             :boolean          default(TRUE)
#  summary                    :string
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_intervention_types_on_intervention_type_group_id  (intervention_type_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (intervention_type_group_id => intervention_type_groups.id) ON DELETE => cascade
#

class InterventionType < ApplicationRecord
  extend Mobility
  include TransifexSerialisable
  include Searchable
  include TranslatableAttachment

  TX_REWRITEABLE_FIELDS = [:description_cy, :download_links_cy].freeze

  VALID_FUEL_TYPES = [:gas, :electricity, :solar, :storage_heater].freeze

  translates :name, type: :string, fallbacks: { cy: :en }
  translates :summary, type: :string, fallbacks: { cy: :en }
  translates :description, backend: :action_text
  translates :download_links, backend: :action_text

  belongs_to :intervention_type_group
  has_many :observations

  has_many :intervention_type_suggestions
  has_many :suggested_types, through: :intervention_type_suggestions

  t_has_one_attached :image

  has_many :link_rewrites, as: :rewriteable

  accepts_nested_attributes_for :link_rewrites, reject_if: proc { |attributes| attributes[:source].blank? }, allow_destroy: true

  accepts_nested_attributes_for :intervention_type_suggestions, reject_if: proc { |attributes| attributes[:suggested_type_id].blank? }, allow_destroy: true

  validates :intervention_type_group, :name, presence: true
  validates :name, uniqueness: { scope: :intervention_type_group_id }
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :all_fuel_types_are_in_valid_fuel_types_list

  scope :by_name,               -> { order(name: :asc) }
  scope :by_id,                 -> { order(id: :asc) }
  scope :active,                -> { where(active: true) }
  scope :display_order,         -> { order(:custom, :name) }
  scope :not_custom,            -> { where(custom: false) }
  scope :active_and_not_custom, -> { active.not_custom }
  scope :custom_last,           -> { order(:custom) }
  scope :between, ->(first_date, last_date) { where('at BETWEEN ? AND ?', first_date, last_date) }

  before_save :copy_searchable_attributes

  def actions_for_school(school)
    observations.for_school(school)
  end

  #override default name for this resource in transifex
  def tx_name
    name
  end

  def self.tx_resources
    active.order(:id)
  end

  private

  def all_fuel_types_are_in_valid_fuel_types_list
    return if fuel_type.compact.empty?
    invalid_fuel_types = (fuel_type.map(&:to_s) - VALID_FUEL_TYPES.map(&:to_s))
    return if invalid_fuel_types.empty?
    errors.add(:fuel_type, I18n.t('intervention_types.errors.invalid_fuel_type', count: invalid_fuel_types.count) + invalid_fuel_types.to_sentence)
  end

  def copy_searchable_attributes
    self.write_attribute(:name, self.name(locale: :en))
  end
end
