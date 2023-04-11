module Admin
  module SchoolGroups
    class UsersController < AdminController
      load_and_authorize_resource :school_group

      def show
        @group_admins = @school_group.users.sort_by(&:email)
        @school_users = school_users
      end

      private

      def school_users
        users = {}
        @school_group.schools.each do |school|
          users[school] = (school.users + school.cluster_users).uniq.sort_by(&:email)
        end
        users
      end
    end
  end
end
