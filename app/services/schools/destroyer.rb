# frozen_string_literal: true

module Schools
  class Destroyer
    def initialize(before_date: 3.years.ago)
      @before_date = before_date
    end

    def perform!
      make_archived_schools_deleted!
      destroy_deleted_schools!
    end

    private

    # Ensure any schools archived before threshold are updated to be deleted.
    # Will ensure that users are unlinked from the school, unvalidated meter data is deleted and issues are removed
    def make_archived_schools_deleted!
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
          Rollbar.error(e, :make_archived_schools_deleted!, school_slug: school.slug, school: school.name)
        end
      end
    end

    def destroy_deleted_schools!
      School.deleted.where(removal_date: ..@before_date).find_each do |school|
        school.transaction do
          school.destroy!
        end
      rescue StandardError => e
        Rollbar.error(e, :destroy_deleted_schools!, school_slug: school.slug, school: school.name)
      end
    end
  end
end
