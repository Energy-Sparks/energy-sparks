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
#  preferred_locale       :string           default("en"), not null
#  pupil_password         :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          default("guest"), not null
#  school_group_id        :bigint(8)
#  school_id              :bigint(8)
#  sign_in_count          :integer          default(0), not null
#  staff_role_id          :bigint(8)
#  unlock_token           :string
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
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#  fk_rails_...  (staff_role_id => staff_roles.id) ON DELETE => restrict
#

require 'securerandom'

class User < ApplicationRecord
  attribute :pupil_password, EncryptedField::Type.new

  belongs_to :school, optional: true
  belongs_to :staff_role, optional: true
  belongs_to :school_group, optional: true
  has_many :contacts
  has_many :consent_grants, inverse_of: :user, dependent: :nullify

  has_many :school_onboardings, inverse_of: :created_user, foreign_key: :created_user_id

  has_and_belongs_to_many :cluster_schools, class_name: 'School', join_table: :cluster_schools_users

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :lockable, :confirmable

  enum role: [:guest, :staff, :admin, :school_admin, :school_onboarding, :pupil, :group_admin, :analytics, :volunteer]

  scope :alertable, -> { where(role: [User.roles[:staff], User.roles[:school_admin], User.roles[:volunteer]]) }

  scope :recently_logged_in, ->(date) { where('last_sign_in_at >= ?', date) }
  validates :email, presence: true

  validates :pupil_password, presence: true, if: :pupil?
  validates :pupil_password, length: { minimum: 12 }, if: :pupil?
  validate :pupil_password_unique, if: :pupil?

  validates :staff_role_id, :school_id, presence: true, if: :staff?
  validates :staff_role_id, :school_id, presence: true, if: :school_admin?
  validates :staff_role_id, presence: true, if: :school_onboarding?

  validates :school_id, presence: true, if: :pupil?

  validates :school_group_id, presence: true, if: :group_admin?

  validate :preferred_locale_presence_in_available_locales

  after_save :update_contact

  def default_scoreboard
    if group_admin? && school_group.default_scoreboard
      school_group.default_scoreboard
    elsif school
      school.scoreboard
    end
  end

  def display_name
    name.present? ? name : email
  end

  def staff_role_as_symbol
    return nil unless staff_role
    staff_role.as_symbol
  end

  def cluster_schools_for_switching
    cluster_schools.visible.by_name.excluding(school)
  end

  def add_cluster_school(school)
    cluster_schools << school unless cluster_schools.include?(school)
  end

  def has_other_schools?
    cluster_schools.excluding(school).any?
  end

  def self.find_school_users_linked_to_other_schools(school_id:, user_ids:)
    User.joins(:cluster_schools_users)
        .where.not('cluster_schools_users.school_id' => school_id)
        .where('cluster_schools_users.user_id in (?)', user_ids)
  end

  def remove_school(school_to_remove)
    cluster_schools.delete(school_to_remove)
    if school == school_to_remove
      if cluster_schools.any?
        update!(school: cluster_schools.last)
      else
        update!(school: nil, role: :school_onboarding)
      end
    end
  end

  def schools
    return School.visible.by_name if self.admin?
    return school_group.schools.visible.by_name if self.school_group
    [school].compact
  end

  def school_name
    school.name if school
  end

  def default_school_group
    if group_admin? && school_group
      school_group
    else
      school&.school_group
    end
  end

  def school_group_name
    school_group&.name
  end

  def default_school_group_name
    default_school_group&.name
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

  def contact_for_school
    contacts.for_school(school).first
  end

  def after_confirmation
    OnboardingMailer.with_user_locales(users: [self], school: school) { |mailer| mailer.welcome_email.deliver_now } if self.school.present?
  end

  def self.admin_user_export_csv
    CSV.generate do |csv|
      csv << [
        'School Group',
        'School',
        'School type',
        'Funder',
        'Region',
        'Name',
        'Email',
        'Role',
        'Staff Role',
        'Locked'
      ]
      where.not(role: [:pupil, :admin]).order(:email).each do |user|
        csv << [
          user.default_school_group_name || '',
          user.school&.name || '',
          user.school&.school_type&.humanize || '',
          user.school&.funder&.name || '',
          user.school&.region&.to_s&.titleize || '',
          user.name,
          user.email,
          user.role.titleize,
          user.staff_role&.title || '',
          user.access_locked? ? 'Yes' : 'No'
        ]
      end
    end
  end

protected

  def preferred_locale_presence_in_available_locales
    return if I18n.available_locales.include? preferred_locale&.to_sym

    errors.add(:preferred_locale, 'must be present in the list of availale locales')
  end

  def password_required?
    confirmed? ? super : false
  end

  def update_contact
    if (contact = contact_for_school)
      contact.populate_from_user(self)
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
