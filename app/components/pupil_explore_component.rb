class PupilExploreComponent < ApplicationComponent
  attr_reader :school, :fuel_type, :icon, :icon_set

  renders_one :note

  renders_one :link, types: {
    category: {
      renders: lambda { |**args| 'PupilExploreComponent::CategoryLink'.constantize.new(school: @school, fuel_type: @fuel_type, **args) },
      as: :category
    },
    chart: {
       renders: lambda { |**args| 'PupilExploreComponent::ChartLink'.constantize.new(school: @school, fuel_type: @fuel_type, **args) },
       as: :chart_link
    },
    usage_chart: {
       renders: lambda { |**args| 'PupilExploreComponent::UsageChartLink'.constantize.new(school: @school, fuel_type: @fuel_type, **args) },
       as: :usage_link
    }
  }

  def initialize(school:, fuel_type:, icon:, icon_set: 'fas', id: nil, classes: '')
    super(id: id, classes: classes)
    @school = school
    @fuel_type = fuel_type
    @icon = icon
    @icon_set = icon_set
  end

  def render?
    link? && link.render?
  end

  class CategoryLink < ViewComponent::Base
    def initialize(school:, fuel_type:, link_text:, category:)
      @school = school
      @fuel_type = fuel_type
      @link_text = link_text
      @category = category
    end

    def call
      link_to @link_text,
              pupils_school_analysis_path(@school, category: @category),
              class: 'stretched-link'
    end
  end

  class ChartLink < ViewComponent::Base
    def initialize(school:, fuel_type:, link_text:, **kwargs)
      @school = school
      @fuel_type = fuel_type
      @link_text = link_text
      @config = kwargs
    end

    def call
      link_to @link_text,
              pupils_school_analysis_tab_path(@school, @config),
              class: 'stretched-link'
    end

    def render?
      !@school.configuration.get_charts(:pupil_analysis_charts, :pupil_analysis_page, *@config.values).empty?
    end
  end

  class UsageChartLink < ViewComponent::Base
    def initialize(school:, fuel_type:, link_text:, supply: nil, **kwargs)
      @school = school
      @fuel_type = fuel_type
      @link_text = link_text
      @supply = supply
      @config = kwargs
    end

    def call
      link_to @link_text,
              school_usage_path(@school, { supply: @supply || @fuel_type }.merge(@config)),
              class: 'stretched-link'
    end
  end
end
