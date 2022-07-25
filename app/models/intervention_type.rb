# == Schema Information
#
# Table name: intervention_types
#
#  active                     :boolean          default(TRUE)
#  created_at                 :datetime         not null
#  custom                     :boolean          default(FALSE)
#  id                         :bigint(8)        not null, primary key
#  intervention_type_group_id :bigint(8)        not null
#  name                       :string           not null
#  score                      :integer
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
  translates :name, type: :string, fallbacks: { cy: :en }
  translates :summary, type: :string, fallbacks: { cy: :en }
  translates :description, backend: :action_text
  translates :download_links, backend: :action_text

  include PgSearch::Model
  pg_search_scope :search,
                  against: [:name],
                  associated_against: {
                    rich_text_description: [:body]
                  },
                  using: {
                    tsearch: {
                      dictionary: 'english'
                    }
                  }

  belongs_to :intervention_type_group
  has_many :observations

  has_many :intervention_type_suggestions
  has_many :suggested_types, through: :intervention_type_suggestions

  has_one_attached :image

  accepts_nested_attributes_for :intervention_type_suggestions, reject_if: proc { |attributes| attributes[:suggested_type_id].blank? }, allow_destroy: true

  validates :intervention_type_group, :name, presence: true
  validates :name, uniqueness: { scope: :intervention_type_group_id }
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :by_name,               -> { order(name: :asc) }
  scope :active,                -> { where(active: true) }
  scope :display_order,         -> { order(:custom, :name) }
  scope :not_custom,            -> { where(custom: false) }
  scope :active_and_not_custom, -> { active.not_custom }

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

  def copy_searchable_attributes
    self.write_attribute(:name, self.name(locale: :en))
  end
end
