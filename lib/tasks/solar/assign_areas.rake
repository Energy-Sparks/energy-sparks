namespace :solar do
  desc "Assign PV Live Areas"
  task assign_areas: [:environment] do
    puts "#{DateTime.now.utc} Reassign solar areas start"

    # Reassociate all schools, using the currently active areas
    # Intended for use after repopulating the list of areas but before we've cleaned out old areas
    #
    # Don't force a reload now to avoid submitting multiple jobs for same area
    School.all.each do |school|
      Solar::SolarAreaLookupService.new(school).assign(scope: SolarPvTuosArea.active.assignable, trigger_load: false)
    end

    # Disable areas without any schools
    SolarPvTuosArea.active.each do |area|
      area.update(active: false) unless area.schools.any?
    end

    puts "#{DateTime.now.utc} Reassign solar areas end"
  end
end
