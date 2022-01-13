# == Schema Information
#
# Table name: audits
#
#  completed_on :date
#  created_at   :datetime         not null
#  id           :bigint(8)        not null, primary key
#  published    :boolean          default(TRUE)
#  school_id    :bigint(8)        not null
#  title        :string           not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_audits_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class Audit < ApplicationRecord
  belongs_to :school, inverse_of: :audits
  has_one_attached :file
  has_rich_text :description

  has_many :observations, dependent: :destroy

  validates_presence_of :school, :title

  has_many :audit_activity_types
  has_many :activity_types, through: :audit_activity_types
  accepts_nested_attributes_for :audit_activity_types, allow_destroy: true

  has_many :audit_intervention_types
  has_many :intervention_types, through: :audit_intervention_types
  accepts_nested_attributes_for :audit_intervention_types, allow_destroy: true

  scope :published, -> { where(published: true) }
  scope :by_date,   -> { order(created_at: :desc) }
end
