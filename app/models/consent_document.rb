# == Schema Information
#
# Table name: consent_documents
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  school_id  :bigint(8)
#  title      :text             not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_consent_documents_on_school_id  (school_id)
#
class ConsentDocument < ApplicationRecord
  belongs_to :school
  has_one_attached :file
  has_rich_text :description

  has_and_belongs_to_many :meter_reviews

  scope :by_created_date, -> { order(created_at: :asc) }

  validates_presence_of :school, :title, :file, presence: true
end
