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
#  id                     :bigint(8)        not null, primary key
#  name                   :string
#  score                  :integer
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
  translates :name, type: :string, fallbacks: { cy: :en }
  translates :summary, type: :string, fallbacks: { cy: :en }
  translates :description, backend: :action_text
  translates :school_specific_description, backend: :action_text
  translates :download_links, backend: :action_text

  include PgSearch::Model

  TX_ATTRIBUTE_MAPPING = {
    school_specific_description: { templated: true },
  }.freeze

  belongs_to :activity_category

  has_one_attached :image
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

  accepts_nested_attributes_for :activity_type_suggestions, reject_if: proc { |attributes| attributes[:suggested_type_id].blank? }, allow_destroy: true

  before_save :copy_searchable_attributes

  pg_search_scope :full_search,
                  # against: [:name],
                  associated_against: {
                    rich_text_description: [:body],
                    string_translations: [:value]
                  },
                  using: {
                    tsearch: {
                      dictionary: 'english'
                    }
                  }

  def self.search(query:, locale: 'en')
    joins(build_search_sql_for(query, locale))
  end

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

  class << self
    def build_search_sql_for(query, locale)
      dictionary = locale.to_s == 'en' ? 'english' : 'simple'

      search_sql = <<-SQL.squish
        INNER JOIN (
          SELECT "activity_types"."id" AS search_id, (
            ts_rank(
              (
                to_tsvector('#{dictionary}', coalesce(action_text_rich_texts_results.action_text_rich_texts_body::text, ''))
                ||
                to_tsvector('#{dictionary}', coalesce(mobility_string_translations_results.mobility_string_translations_value::text, ''))
              ),
              (
                to_tsquery('#{dictionary}', ''' ' || '#{query}' || ' ''')
              ), 0
            )
          ) AS rank FROM "activity_types"

          LEFT OUTER JOIN (
            SELECT "activity_types"."id" AS id, "action_text_rich_texts"."body"::text AS action_text_rich_texts_body
            FROM "activity_types"
            INNER JOIN "action_text_rich_texts" ON "action_text_rich_texts"."record_type" = 'ActivityType'
            AND "action_text_rich_texts"."name" = 'description'
            AND "action_text_rich_texts"."locale" = '#{locale}'
            AND "action_text_rich_texts"."record_id" = "activity_types"."id"
            WHERE "activity_types"."active" = 'true'
          ) action_text_rich_texts_results ON action_text_rich_texts_results.id = "activity_types"."id"

          LEFT OUTER JOIN (
            SELECT "activity_types"."id" AS id, string_agg("mobility_string_translations"."value"::text, ' ') AS mobility_string_translations_value
            FROM "activity_types"
            INNER JOIN "mobility_string_translations" ON "mobility_string_translations"."translatable_type" = 'ActivityType'
            AND "mobility_string_translations"."key" IN ('name', 'summary')
            AND "mobility_string_translations"."translatable_id" = "activity_types"."id"
            AND "mobility_string_translations"."locale" = '#{locale}'
            WHERE "activity_types"."active" = 'true'
            GROUP BY "activity_types"."id"
          ) mobility_string_translations_results ON mobility_string_translations_results.id = "activity_types"."id"

          WHERE (
            (
              to_tsvector('#{dictionary}', coalesce(action_text_rich_texts_results.action_text_rich_texts_body::text, ''))
              ||
              to_tsvector('#{dictionary}', coalesce(mobility_string_translations_results.mobility_string_translations_value::text, ''))
            )
            @@
            (
              to_tsquery('#{dictionary}', ''' ' || '#{query}' || ' ''')
            )
          )
        ) AS activity_type_results ON "activity_types"."id" = activity_type_results.search_id

        ORDER BY activity_type_results.rank DESC, "activity_types"."id" ASC
      SQL
      search_sql
    end
  end

  private

  def copy_searchable_attributes
    self.write_attribute(:name, self.name(locale: :en))
  end
end
