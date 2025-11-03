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
#  maximum_frequency          :integer          default(10)
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
  include FuelTypeable
  include Recordable

  TX_REWRITEABLE_FIELDS = [:description_cy, :download_links_cy].freeze

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

  has_many :alert_type_rating_intervention_types, dependent: nil
  has_many :alert_type_ratings, through: :alert_type_rating_intervention_types

  # old relationships to be removed when todos feature removed
  has_many :audit_intervention_types, dependent: nil
  has_many :audits, through: :audit_intervention_types

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
  scope :between,               ->(first_date, last_date) { where('at BETWEEN ? AND ?', first_date, last_date) }
  scope :not_including,         ->(records = []) { where.not(id: records) }
  scope :tx_resources,          -> { active.order(:id) }

  before_save :copy_searchable_attributes

  def actions_for_school(school)
    observations.visible.for_school(school)
  end

  # override default name for this resource in transifex
  def tx_name
    name
  end

  def count_existing_for_academic_year(school, academic_year)
    school.observations.where(intervention_type: self).in_academic_year(academic_year).with_points.count
  end

  def public_type
    :action
  end

  private

  def copy_searchable_attributes
    self.write_attribute(:name, self.name(locale: :en))
  end

  class << self
    private

    def searchable_filter(show_all: false)
      if show_all
        %|"#{table_name}"."active" in ('true', 'false') AND "#{table_name}"."custom" = 'false'|
      else
        %|"#{table_name}"."active" = 'true' AND "#{table_name}"."custom" = 'false'|
      end
    end

    def searchable_body_field
      'description'
    end

    def searchable_metadata_fields
      %w[name summary]
    end
  end
end
