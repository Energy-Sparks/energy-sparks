# == Schema Information
#
# Table name: users
#
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  created_at             :datetime         not null
#  created_by_id          :bigint(8)
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
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_created_by_id         (created_by_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_school_group_id       (school_group_id)
#  index_users_on_school_id             (school_id)
#  index_users_on_staff_role_id         (staff_role_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (school_group_id => school_groups.id) ON DELETE => restrict
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#  fk_rails_...  (staff_role_id => staff_roles.id) ON DELETE => restrict
#

require 'securerandom'

class User < ApplicationRecord
  encrypts :pupil_password

  belongs_to :school, optional: true
  belongs_to :staff_role, optional: true
  belongs_to :school_group, optional: true
  belongs_to :created_by, class_name: :User, optional: true
  has_many :contacts
  has_many :consent_grants, inverse_of: :user, dependent: :nullify
  has_many :users_created, class_name: :User, inverse_of: :created_by, dependent: :nullify

  has_many :school_onboardings, inverse_of: :created_user, foreign_key: :created_user_id
  has_many :issues_admin_for, class_name: 'SchoolGroup', inverse_of: :default_issues_admin_user,
                              foreign_key: :default_issues_admin_user_id, dependent: nil

  has_many :observations_created, class_name: 'Observation', inverse_of: :created_by, dependent: :nullify
  has_many :observations_updated, class_name: 'Observation', inverse_of: :updated_by, dependent: :nullify

  has_and_belongs_to_many :cluster_schools, class_name: 'School', join_table: :cluster_schools_users

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :lockable, :confirmable

  enum :role, { guest: 0, staff: 1, admin: 2, school_admin: 3, school_onboarding: 4, pupil: 5,
                group_admin: 6, analytics: 7, volunteer: 8 }

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
    name.presence || email
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
    return unless school == school_to_remove

    if cluster_schools.any?
      update!(school: cluster_schools.last)
    else
      update!(school: nil, role: :school_onboarding)
    end
  end

  def schools
    return School.visible.by_name if admin?
    return school_group.schools.visible.by_name if school_group

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
        school:,
        email: "#{school.id}-#{SecureRandom.uuid}@pupils.#{ENV.fetch('APPLICATION_HOST', nil)}",
        password: SecureRandom.uuid,
        confirmed_at: Time.zone.now
      )
    )
  end

  def self.new_staff(school, attributes)
    new(
      attributes.merge(
        role: :staff,
        school:
      )
    )
  end

  def self.new_school_admin(school, attributes)
    new(
      attributes.merge(
        role: :school_admin,
        school:
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
    return unless school.present?

    OnboardingMailer.with_user_locales(users: [self], school:) do |mailer|
      mailer.welcome_email.deliver_now
    end
  end

  def self.admin_user_export_csv
    CSV.generate do |csv|
      csv << [
        'School Group',
        'School',
        'School type',
        'School active',
        'School data enabled',
        'Funder',
        'Region',
        'Name',
        'Email',
        'Role',
        'Staff Role',
        'Confirmed',
        'Locked'
      ]
      where.not(role: %i[pupil admin]).order(:email).each do |user|
        csv << [
          user.default_school_group_name || '',
          user.school&.name || '',
          user.school&.school_type&.humanize || '',
          if user.school
            user.school&.active? ? 'Yes' : 'No'
          else
            ''
          end,
          if user.school
            user.school&.data_enabled? ? 'Yes' : 'No'
          else
            ''
          end,
          user.school&.funder&.name || '',
          user.school&.region&.to_s&.titleize || '',
          user.name,
          user.email,
          user.role.titleize,
          user.staff_role&.title || '',
          user.confirmed? ? 'Yes' : 'No',
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
    return unless (contact = contact_for_school)

    contact.populate_from_user(self)
    contact.save
  end

  def pupil_password_unique
    return if pupil_password.blank?

    existing_user = school.authenticate_pupil(pupil_password)
    return unless existing_user && existing_user != self

    errors.add(:pupil_password, "is already in use for '#{existing_user.name}'")
  end
end
