# == Schema Information
#
# Table name: users
#
#  active                      :boolean          default(TRUE), not null
#  confirmation_sent_at        :datetime
#  confirmation_token          :string
#  confirmed_at                :datetime
#  created_at                  :datetime         not null
#  created_by_id               :bigint(8)
#  current_sign_in_at          :datetime
#  current_sign_in_ip          :inet
#  email                       :string           default(""), not null
#  encrypted_password          :string           default(""), not null
#  failed_attempts             :integer          default(0), not null
#  id                          :bigint(8)        not null, primary key
#  last_sign_in_at             :datetime
#  last_sign_in_ip             :inet
#  locked_at                   :datetime
#  mailchimp_fields_changed_at :datetime
#  mailchimp_status            :enum
#  mailchimp_updated_at        :datetime
#  name                        :string
#  preferred_locale            :string           default("en"), not null
#  pupil_password              :string
#  remember_created_at         :datetime
#  reset_password_sent_at      :datetime
#  reset_password_token        :string
#  role                        :integer          default("guest"), not null
#  school_group_id             :bigint(8)
#  school_id                   :bigint(8)
#  sign_in_count               :integer          default(0), not null
#  staff_role_id               :bigint(8)
#  unlock_token                :string
#  updated_at                  :datetime         not null
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

class User < ApplicationRecord
  include MailchimpUpdateable

  watch_mailchimp_fields :confirmed_at, :name, :preferred_locale, :school_id, :school_group_id, :role, :staff_role_id,
                         :active
  after_destroy :reset_mailchimp_contact

  before_save :enforce_role_associations, if: :role_changed?

  after_save :update_contact
  # Email is primary key in Mailchimp, trigger immediate update if its is changed, otherwise
  # subsequent updates will fail
  after_commit :update_email_in_mailchimp, if: :email_previously_changed?

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
                              foreign_key: :default_issues_admin_user_id, dependent: :nullify

  has_many :observations_created, class_name: 'Observation', inverse_of: :created_by, dependent: :nullify
  has_many :observations_updated, class_name: 'Observation', inverse_of: :updated_by, dependent: :nullify
  has_many :energy_tariffs_created, class_name: 'EnergyTariff', inverse_of: :created_by, dependent: :nullify
  has_many :energy_tariffs_updated, class_name: 'EnergyTariff', inverse_of: :updated_by, dependent: :nullify
  has_many :issues_created, class_name: 'Issue', inverse_of: :created_by, dependent: :nullify
  has_many :issues_updated, class_name: 'Issue', inverse_of: :updated_by, dependent: :nullify
  has_many :activities_updated, class_name: 'Activity', inverse_of: :updated_by, dependent: :nullify

  has_and_belongs_to_many :cluster_schools, class_name: 'School', join_table: :cluster_schools_users

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :lockable, :confirmable

  # volunteer has been removed, this was 8
  enum :role, { guest: 0, staff: 1, admin: 2, school_admin: 3, school_onboarding: 4, pupil: 5,
                group_admin: 6, analytics: 7 }

  enum :mailchimp_status, %w[subscribed unsubscribed cleaned nonsubscribed archived].to_h { |v| [v, v] }, prefix: true

  scope :active, -> { where(active: true) }

  scope :alertable, -> { where(role: [User.roles[:staff], User.roles[:school_admin]]) }

  scope :mailchimp_roles, lambda {
    where.not(role: %i[pupil school_onboarding]).where.not(confirmed_at: nil)
  }

  scope :mailchimp_update_required, lambda {
    joins('LEFT JOIN schools ON schools.id = users.school_id')
      .joins('LEFT JOIN school_groups ON school_groups.id = users.school_group_id')
      .joins('LEFT JOIN funders ON funders.id = schools.funder_id')
      .joins('LEFT JOIN local_authority_areas ON local_authority_areas.id = schools.local_authority_area_id')
      .joins('LEFT JOIN scoreboards ON scoreboards.id = schools.scoreboard_id')
      .joins('LEFT JOIN staff_roles ON staff_roles.id = users.staff_role_id')
      .where.not(mailchimp_status: nil) # only include users already in mailchimp for now
      # include any we've not pushed to mailchimp, or any that are out of date based on timestamps
      .where('mailchimp_updated_at IS NULL OR ' \
             'GREATEST(users.mailchimp_fields_changed_at, schools.mailchimp_fields_changed_at,  ' \
             'school_groups.mailchimp_fields_changed_at, funders.mailchimp_fields_changed_at,  ' \
             'local_authority_areas.mailchimp_fields_changed_at, scoreboards.mailchimp_fields_changed_at,  ' \
             'staff_roles.mailchimp_fields_changed_at) > mailchimp_updated_at')
  }

  scope :for_school_group, lambda { |school_group|
    joins(:school, school: :school_group).where(schools: { school_group: school_group })
  }

  scope :recently_logged_in, ->(date) { where('last_sign_in_at >= ?', date) }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :pupil_password, presence: true, if: :pupil?
  validates :pupil_password, length: { minimum: 12 }, if: :pupil?
  validate :pupil_password_unique, if: :pupil?

  validates :staff_role_id, :school_id, presence: true, if: :staff?
  validates :staff_role_id, :school_id, presence: true, if: :school_admin?
  validates :staff_role_id, presence: true, if: :school_onboarding?

  validates :school_id, presence: true, if: :pupil?

  validates :school_group_id, presence: true, if: :group_admin?

  validates :name, presence: true, on: :create
  validates :name, presence: true, on: :form_update

  validate :preferred_locale_presence_in_available_locales

  # Hook into devise so we can use our own status flag to permanently disable an account
  def active_for_authentication?
    active && super
  end

  def inactive?
    !active?
  end

  def disable!
    update!(active: false)
  end

  def enable!
    update!(active: true)
  end

  def default_scoreboard
    if group_admin? && school_group.default_scoreboard
      school_group.default_scoreboard
    elsif school
      school.scoreboard
    end
  end

  def has_profile?
    !(pupil? || school_onboarding?)
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
    touch_mailchimp_timestamp!
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
    touch_mailchimp_timestamp!
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
        email: "#{school.id}-#{SecureRandom.uuid}@pupils.#{ENV.fetch('APPLICATION_HOST', 'energysparks.uk')}",
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
    OnboardingMailer.mailer.with(user: self, school:).welcome_email.deliver_now if school&.visible
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

  def self.admins_by_name
    admin.sort_by { |user| user.display_name.downcase }
  end

  # For Mailchimp fields, don't use in other contexts
  def mailchimp_organisation
    if school.present?
      school.name
    elsif school_group.present?
      school_group.name
    else
      ''
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

  private

  def enforce_role_associations
    # when becoming a group admin remove individual school associations
    if role_changed?(from: 'school_admin', to: 'group_admin')
      self.cluster_schools.destroy_all
    end

    # when becoming a school admin remove link to school group
    if role_changed?(from: 'group_admin', to: 'school_admin')
      self.school_group = nil
    end
  end

  def reset_mailchimp_contact
    return unless mailchimp_status.present?

    Mailchimp::UserDeletionJob.perform_later(
      email_address: email,
      name: name,
      school: mailchimp_organisation
    )
  end

  def update_email_in_mailchimp
    return unless email_previously_was.present? && mailchimp_status.present?

    Mailchimp::EmailUpdaterJob.perform_later(
      user: self,
      original_email: email_previously_was
    )
  end
end
