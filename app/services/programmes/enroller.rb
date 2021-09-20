module Programmes
  class Enroller
    def initialize(programme_type = nil)
      @enrol_programme_type = programme_type_or_default(programme_type)
    end

    def enrol(school)
      return unless enrol?(school)
      Programmes::Creator.new(school, @enrol_programme_type).create
    end

    def enrol_all
      return unless enrol?(school)
      School.visible.each do |school|
        enrol(school)
      end
    end

    private

    def programme_type_or_default(programme_type)
      programme_type || ProgrammeType.default.first
    end

    def enrol?(school)
      @enrol_programme_type.present? && Targets::SchoolTargetService.targets_enabled?(school)
    end
  end
end
