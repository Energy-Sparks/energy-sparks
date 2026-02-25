module Admin
  class UserListComponent < ApplicationComponent
    def initialize(id: nil, classes: '', users: nil, schools: nil, show_organisation: true)
      super(id: id, classes: classes)
      @users = users
      @schools = schools
      @show_organisation = show_organisation
    end

    def render?
      @users&.any? || @schools&.any?
    end

    def show_organisation?
      @show_organisation
    end

    def users_to_display
      if @users&.any?
        @users.each do |user|
          yield user
        end
      else
        @schools.each do |school|
          school_users = (school.users + school.cluster_users).uniq.sort_by(&:email)
          school_users.each do |user|
            yield user
          end
        end
      end
    end

    def row_class(user)
      if !user.active?
        'table-danger'
      elsif user.access_locked?
        'table-warning'
      else
        ''
      end
    end
  end
end
