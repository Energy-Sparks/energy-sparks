# == Schema Information
#
# Table name: programmes
#
#  ended_on          :date
#  id                :bigint(8)        not null, primary key
#  programme_type_id :bigint(8)
#  school_id         :bigint(8)
#  started_on        :date
#  status            :integer          default("started"), not null
#  title             :text
#
# Indexes
#
#  index_programmes_on_programme_type_id  (programme_type_id)
#  index_programmes_on_school_id          (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (programme_type_id => programme_types.id) ON DELETE => cascade
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class Programme < ApplicationRecord
  belongs_to :programme_type
  belongs_to :school
  has_many :programme_activities

  delegate :description, to: :programme_type

  enum status: [:started, :completed, :abandoned]
end
