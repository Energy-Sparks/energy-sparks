module SchoolGroups
  class CurrentScoresCsvGenerator
    def initialize(school_group:)
      @school_group = school_group
    end

    def export
      CSV.generate(headers: true) do |csv|
        csv << headers
        @school_group.scored_schools.with_points.schools_with_positions.each do |position, schools|
          schools.each do |school|
            csv << [
              (schools.size > 1 ? '=' : '') + position.to_s,
              school.name,
              school.sum_points
            ]
          end
        end
        @school_group.scored_schools.without_points.each { |school| csv << ['-', school.name, 0] }
      end
    end

    private

    def headers
      [
        I18n.t('scoreboard.position'),
        I18n.t('common.school'),
        I18n.t('scoreboard.score')
      ]
    end
  end
end
