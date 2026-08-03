# frozen_string_literal: true

module Schools
  class Destroyer
    def initialize(before_date: 3.years.ago)
      @before_date = before_date
    end

    def perform!
      destroy_archived_schools
      destroy_deleted_schools
    end

    private

    # Archiving schools skips some changes to users and meter data that are normally carried out when a school is
    # soft-deleted. So ensure those steps are completed first, using the Remover class, before destroying the school.
    def destroy_archived_schools
      School.archived.where(archived_date: ..@before_date).find_each do |school|
        remover = Remover.new(school)
        begin
          school.transaction do
            remover.remove_users! # deactivate users, remove association with school if user has multiple schools
            remover.remove_meters! # deactivate meters, removing consent via API call if needed
            school.destroy!
          end
        rescue StandardError => e
          EnergySparks::Log.exception(e, school_slug: school.slug)
        end
      end
    end

    # Assumes school was soft deleted using the Remover, so safe to just destroy the school.
    def destroy_deleted_schools
      School.deleted.where(removal_date: ..@before_date).find_each do |school|
        school.transaction do
          school.destroy!
        end
      rescue StandardError => e
        EnergySparks::Log.exception(e, school_slug: school.slug)
      end
    end
  end
end
