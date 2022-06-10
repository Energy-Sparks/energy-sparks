# == Schema Information
#
# Table name: intervention_types
#
#  active                     :boolean          default(TRUE)
#  custom                     :boolean          default(FALSE)
#  id                         :bigint(8)        not null, primary key
#  intervention_type_group_id :bigint(8)        not null
#  name                       :string           not null
#  score                      :integer
#  summary                    :string
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
  has_rich_text :description
  has_rich_text :download_links

  accepts_nested_attributes_for :intervention_type_suggestions, reject_if: proc { |attributes| attributes[:suggested_type_id].blank? }, allow_destroy: true

  validates :intervention_type_group, :name, presence: true
  validates :name, uniqueness: { scope: :intervention_type_group_id }
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :by_name,               -> { order(name: :asc) }
  scope :active,                -> { where(active: true) }
  scope :display_order,         -> { order(:custom, :name) }
  scope :not_custom,            -> { where(custom: false) }
  scope :active_and_not_custom, -> { active.not_custom }

  def actions_for_school(school)
    observations.for_school(school)
  end
end
