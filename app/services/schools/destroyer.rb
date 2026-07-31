# frozen_string_literal: true

module Schools
  class Destroyer
    def initialize(before_date: 3.years.ago)
      @before_date = before_date
    end

    def perform!
      soft_delete_archived_schools
      destroy_deleted_schools
    end

    private

    # Ensure any schools archived before threshold are put into same state as other soft deleted schools
    # Will ensure that users are unlinked from the school, unvalidated meter data is deleted and issues are removed
    def soft_delete_archived_schools
      School.archived.where(archived_date: ..@before_date).find_each do |school|
        remover = Remover.new(school)
        begin
          school.transaction do
            remover.remove_users!
            remover.remove_meters!
            remover.remove_school!
            school.update!(removal_date: school.archived_date) # Set to original archive date, so destroyed in next step
          end
        rescue StandardError => e
          EnergySparks::Log.exception(e, :soft_delete_archived_schools, school_slug: school.slug)
        end
      end
    end

    def destroy_deleted_schools
      School.deleted.where(removal_date: ..@before_date).find_each do |school|
        school.transaction do
          school.destroy!
        end
      rescue StandardError => e
        EnergySparks::Log.exception(e, :destroy_deleted_schools, school_slug: school.slug)
      end
    end
  end
end
