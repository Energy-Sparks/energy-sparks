# == Schema Information
#
# Table name: users
#
#  created_at             :datetime         not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  id                     :bigint(8)        not null, primary key
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  locked_at              :datetime
#  name                   :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          default("guest"), not null
#  school_id              :bigint(8)
#  sign_in_count          :integer          default(0), not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_school_id             (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#

class User < ApplicationRecord
  belongs_to :school

  has_many :school_onboardings, inverse_of: :created_user, foreign_key: :created_user_id

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :lockable

  enum role: [:guest, :school_user, :admin, :school_admin, :school_onboarding]

  validates :email, presence: true

  def manages_school?(sid = nil)
    admin? || (sid && school_admin_or_user? && school_id == sid)
  end

  #is the user an administrator of an active school?
  def active_school_admin?
    school_admin_or_user? && school.active?
  end

  def school_admin_or_user?
    school_admin? || school_user?
  end
end
