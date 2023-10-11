module SchoolGroups
  class ComparisonsCsvGenerator
    def initialize(school_group:, advice_page_keys: [], include_cluster: false)
      @school_group = school_group
      @advice_page_keys = advice_page_keys.map(&:to_sym)
      @include_cluster = include_cluster
    end

    def export
      CSV.generate(headers: true) do |csv|
        csv << headers
        @school_group.categorise_schools.each do |fuel_type, advice_pages|
          advice_pages.each do |advice_page_key, comparison|
            next unless add_row_for(advice_page_key)

            SchoolGroupComparisonComponent::CATEGORIES.each do |category|
              comparison[category]&.each do |school|
                row = [
                  I18n.t("common.#{fuel_type}"),
                  I18n.t("advice_pages.#{advice_page_key}.page_title"),
                  school['school_name']
                ]
                row << (school['cluster_name'] || I18n.t('common.labels.not_applicable')) if @include_cluster
                row << I18n.t("advice_pages.benchmarks.#{category}")
                csv << row
              end
            end
          end
        end
      end
    end

    private

    def add_row_for(advice_page_key)
      return true if @advice_page_keys.empty?
      return true if @advice_page_keys.include?(advice_page_key)

      false
    end

    def headers
      columns = [
        I18n.t('advice_pages.index.priorities.table.columns.fuel_type'),
        I18n.t('advice_pages.index.priorities.table.columns.description'),
        I18n.t('common.school')
      ]
      columns << I18n.t('school_groups.clusters.labels.cluster') if @include_cluster
      columns << I18n.t('school_groups.comparisons.category')
      columns
    end
  end
end
