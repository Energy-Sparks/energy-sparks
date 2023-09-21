# == Schema Information
#
# Table name: activity_types
#
#  active                 :boolean          default(TRUE)
#  activity_category_id   :bigint(8)        not null
#  created_at             :datetime         not null
#  custom                 :boolean          default(FALSE)
#  data_driven            :boolean          default(FALSE)
#  deprecated_description :text
#  fuel_type              :string           default([]), is an Array
#  id                     :bigint(8)        not null, primary key
#  name                   :string
#  score                  :integer
#  show_on_charts         :boolean          default(TRUE)
#  summary                :string
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_activity_types_on_active                (active)
#  index_activity_types_on_activity_category_id  (activity_category_id)
#
# Foreign Keys
#
#  fk_rails_...  (activity_category_id => activity_categories.id)
#

class ActivityType < ApplicationRecord
  extend Mobility
  include TransifexSerialisable
  include Searchable
  include TranslatableAttachment

  translates :name, type: :string, fallbacks: { cy: :en }
  translates :summary, type: :string, fallbacks: { cy: :en }
  translates :description, backend: :action_text
  translates :school_specific_description, backend: :action_text
  translates :download_links, backend: :action_text

  TX_ATTRIBUTE_MAPPING = {
    school_specific_description: { templated: true },
  }.freeze

  TX_REWRITEABLE_FIELDS = [:description_cy, :school_specific_description_cy, :download_links_cy].freeze

  VALID_FUEL_TYPES = [:gas, :electricity, :solar, :storage_heater].freeze

  belongs_to :activity_category

  t_has_one_attached :image
  has_and_belongs_to_many :key_stages, join_table: :activity_type_key_stages
  has_and_belongs_to_many :impacts, join_table: :activity_type_impacts
  has_and_belongs_to_many :subjects, join_table: :activity_type_subjects
  has_and_belongs_to_many :topics, join_table: :activity_type_topics
  has_and_belongs_to_many :activity_timings, join_table: :activity_type_timings

  scope :active, -> { where(active: true) }
  scope :not_custom, -> { where(custom: false) }

  scope :active_and_not_custom, -> { active.not_custom }
  scope :data_driven, -> { where(data_driven: true) }

  scope :random_suggestions, -> { active }
  scope :custom_last, -> { order(:custom) }
  scope :by_name, -> { order(name: :asc) }
  scope :by_id, -> { order(id: :asc) }
  scope :live_data, -> { joins(:activity_category).merge(ActivityCategory.live_data) }
  scope :for_key_stages, ->(key_stages) { joins(:key_stages).where(key_stages: { id: key_stages.map(&:id) }).distinct }
  scope :for_subjects, ->(subjects) { joins(:subjects).where(subjects: { id: subjects.map(&:id) }).distinct }

  validates_presence_of :name, :activity_category_id, :score
  validates_uniqueness_of :name, scope: :activity_category_id
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  has_many :activity_type_suggestions
  has_many :suggested_types, through: :activity_type_suggestions
  has_many :programme_activities
  has_many :activities, inverse_of: :activity_type

  has_many :programme_type_activity_types
  has_many :programme_types, through: :programme_type_activity_types

  has_many :audit_activity_types
  has_many :audits, through: :audit_activity_types

  has_many :link_rewrites, as: :rewriteable

  accepts_nested_attributes_for :link_rewrites, reject_if: proc { |attributes| attributes[:source].blank? }, allow_destroy: true

  accepts_nested_attributes_for :activity_type_suggestions, reject_if: proc { |attributes| attributes[:suggested_type_id].blank? }, allow_destroy: true

  before_save :copy_searchable_attributes

  def suggested_from
    ActivityType.joins(:activity_type_suggestions).where("activity_type_suggestions.suggested_type_id = ?", id)
  end

  def referenced_from_find_out_mores
    AlertTypeRating.joins(:alert_type_rating_activity_types).where("alert_type_rating_activity_types.activity_type_id = ?", id)
  end

  def key_stage_list
    key_stages.map(&:name).sort.join(', ')
  end

  def name_with_key_stages
    "#{name} (#{key_stage_list})"
  end

  def school_specific_description_or_fallback
    school_specific_description.blank? ? description : school_specific_description
  end

  def activities_for_school(school)
    activities.for_school(school)
  end

  def grouped_school_count
    activities.group(:school).count
  end

  def unique_school_count
    activities.select(:school_id).distinct.count
  end

  #override default name for this resource in transifex
  def tx_name
    name
  end

  def self.tx_resources
    active.order(:id)
  end

  private

  def copy_searchable_attributes
    self.write_attribute(:name, self.name(locale: :en))
  end
end
