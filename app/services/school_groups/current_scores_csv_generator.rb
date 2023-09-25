module SchoolGroups
  class CurrentScoresCsvGenerator
    def initialize(school_group:, scored_schools: nil, include_cluster: false)
      @school_group = school_group
      @scored_schools = scored_schools || @school_group.scored_schools
      @include_cluster = include_cluster
    end

    def export
      CSV.generate(headers: true) do |csv|
        csv << headers
        @scored_schools.with_points.schools_with_positions.each do |position, schools|
          schools.each do |school|
            row = [
              (schools.size > 1 ? '=' : '') + position.to_s,
              school.name
            ]
            row << school.school_group_cluster_name if @include_cluster
            row << school.sum_points
            csv << row
          end
        end
        @scored_schools.without_points.each do |school|
          row = ['-', school.name]
          row << school.school_group_cluster_name if @include_cluster
          row << 0
          csv << row
        end
      end
    end

    private

    def headers
      columns = [
        I18n.t('scoreboard.position'),
        I18n.t('common.school')
      ]
      columns << I18n.t('school_groups.clusters.labels.cluster') if @include_cluster
      columns << I18n.t('scoreboard.score')
      columns
    end
  end
end
