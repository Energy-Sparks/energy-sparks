# == Schema Information
#
# Table name: users
#
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
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
#  pupil_password         :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          default("guest"), not null
#  school_group_id        :bigint(8)
#  school_id              :bigint(8)
#  sign_in_count          :integer          default(0), not null
#  staff_role_id          :bigint(8)
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token            (confirmation_token) UNIQUE
#  index_users_on_email                         (email) UNIQUE
#  index_users_on_reset_password_token          (reset_password_token) UNIQUE
#  index_users_on_school_group_id               (school_group_id)
#  index_users_on_school_id                     (school_id)
#  index_users_on_school_id_and_pupil_password  (school_id,pupil_password) UNIQUE
#  index_users_on_staff_role_id                 (staff_role_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_group_id => school_groups.id) ON DELETE => restrict
#  fk_rails_...  (school_id => schools.id)
#  fk_rails_...  (staff_role_id => staff_roles.id) ON DELETE => restrict
#

require 'securerandom'

class User < ApplicationRecord
  attribute :pupil_password, EncryptedField::Type.new

  belongs_to :school, optional: true
  belongs_to :staff_role, optional: true
  belongs_to :school_group, optional: true
  has_one :contact

  has_many :school_onboardings, inverse_of: :created_user, foreign_key: :created_user_id

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :lockable, :confirmable

  enum role: [:guest, :staff, :admin, :school_admin, :school_onboarding, :pupil, :group_admin]

  scope :alertable, -> { where(role: [User.roles[:staff], User.roles[:school_admin]]) }

  validates :email, presence: true

  validates :pupil_password, presence: true, if: :pupil?
  validate :pupil_password_unique, if: :pupil?

  validates :staff_role_id, presence: true, if: :staff?
  validates :staff_role_id, presence: true, if: :school_admin?
  validates :staff_role_id, presence: true, if: :school_onboarding?

  after_save :update_contact

  def default_scoreboard
    if group_admin? && school_group.scoreboard
      school_group.scoreboard
    elsif school
      school.scoreboard
    end
  end

  def display_name
    name || email
  end

  def self.new_pupil(school, attributes)
    new(
      attributes.merge(
        role: :pupil,
        school: school,
        email: "#{school.id}-#{SecureRandom.uuid}@pupils.#{ENV['APPLICATION_HOST']}",
        password: SecureRandom.uuid,
        confirmed_at: Time.zone.now
      )
    )
  end

  def self.new_staff(school, attributes)
    new(
      attributes.merge(
        role: :staff,
        school: school
      )
    )
  end

  def self.new_school_admin(school, attributes)
    new(
      attributes.merge(
        role: :school_admin,
        school: school
      )
    )
  end

  def self.new_school_onboarding(attributes)
    new(
      attributes.merge(
        role: :school_onboarding,
        confirmed_at: Time.zone.now
      )
    )
  end

protected

  def password_required?
    confirmed? ? super : false
  end

  def update_contact
    if contact
      contact.popualate_from_user(self)
      contact.save
    end
  end

  def pupil_password_unique
    return if pupil_password.blank?
    existing_user = school.authenticate_pupil(pupil_password)
    if existing_user && existing_user != self
      errors.add(:pupil_password, "is already in use for '#{existing_user.name}'")
    end
  end
end
