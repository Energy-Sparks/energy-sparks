module Admin
  module SchoolGroups
    class UsersController < AdminController
      include ApplicationHelper
      load_and_authorize_resource :school_group

      def show
        @group_admins = @school_group.users.sort_by(&:email)
        @school_users = school_users
        respond_to do |format|
          format.html { }
          format.csv { send_data produce_csv(@school_group, @group_admins, @school_users), filename: filename(@school_group) }
        end
      end

      def lock_all
        @school_group.users.each { |user| user.lock_access!(send_instructions: false) }
        redirect_to admin_school_group_users_path(@school_group), notice: 'All group users locked.'
      end

      private

      def filename(school_group)
        school_group.name.parameterize + '-users.csv'
      end

      def school_users
        users = {}
        @school_group.schools.each do |school|
          users[school] = (school.users + school.cluster_users).uniq.sort_by(&:email)
        end
        users
      end

      def produce_csv(school_group, group_admins, school_users)
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
            'Last signed in',
            'Alerts',
            'Language',
            'Locked'
          ]
          group_admins.each do |user|
            add_user_to_csv(csv, school_group, nil, user)
          end
          school_group.schools.by_name.each do |school|
            school_users[school].each do |user|
              add_user_to_csv(csv, school_group, school, user)
            end
          end
        end
      end

      def add_user_to_csv(csv, school_group, school, user)
        csv << [
          school_group.name,
          school&.name || '',
          school&.school_type&.humanize || '',
          if school
            school&.active? ? 'Yes' : 'No'
          else
            ''
          end,
          if school
            school&.data_enabled? ? 'Yes' : 'No'
          else
            ''
          end,
          school&.funder&.name || '',
          school&.region&.to_s&.titleize || '',
          user.name,
          user.pupil? ? 'N/A' : user.email,
          user.role.titleize,
          user.group_admin? ? 'N/A' : user.staff_role&.title,
          y_n(user.confirmed?),
          display_last_signed_in_as(user),
          user.group_admin? ? 'N/A' : y_n(user.contact_for_school),
          I18n.t("languages.#{user.preferred_locale}"),
          y_n(user.access_locked?)
        ]
      end
    end
  end
end
