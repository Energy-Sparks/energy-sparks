module SchoolGroups
  class ComparisonReportListComponent < ViewComponent::Base
    renders_many :items, types: {
      link: {
        renders: ->(*args, **kwargs, &block) do
          SchoolGroups::ComparisonReportListComponent::Item.new(*args,
                                                       **kwargs.merge(fuel_types: @fuel_types, school_group: @school_group),
                                                       &block)
        end,
        as: :link
      },
      advice_page: {
        renders: ->(*args, **kwargs, &block) do
          SchoolGroups::ComparisonReportListComponent::AdvicePageItem.new(*args,
                                                       **kwargs.merge(fuel_types: @fuel_types, school_group: @school_group),
                                                       &block)
        end,
        as: :advice_page
      },
      named_sublist: {
        renders: ->(*args, **kwargs, &block) do
          SchoolGroups::ComparisonReportListComponent::NamedSubList.new(*args,
                                                               **kwargs.merge(fuel_types: @fuel_types, school_group: @school_group),
                                                               &block)
        end,
        as: :named
      },
      fuel_type_sublist: {
        renders: ->(*args, **kwargs, &block) do
          SchoolGroups::ComparisonReportListComponent::FuelSubList.new(*args,
                                                              **kwargs.merge(fuel_types: @fuel_types, school_group: @school_group),
                                                              &block)
        end,
        as: :fuel_types
      }
    }

    def initialize(school_group:, fuel_types:, **_kwargs)
      @school_group = school_group
      @fuel_types = fuel_types
    end

    erb_template <<-ERB
      <ul>
        <% items.each do |item| %>
          <%= item %>
        <% end %>
      </ul>
    ERB

    class BaseItem < ViewComponent::Base
      def initialize(link_text, fuel_types:, school_group:, fuel_type: nil, **_kwargs)
        @fuel_types = fuel_types
        @school_group = school_group
        @link_text = link_text
        @fuel_type = fuel_type
      end

      def render?
        @fuel_type.nil? || @fuel_types.include?(@fuel_type)
      end

      def report_path(report = @report)
        helpers.compare_path(group_dashboard: true, benchmark: report, school_group_ids: [@school_group.id])
      end
    end

    class Item < BaseItem
      def initialize(link_text, fuel_types:, school_group:, report:, fuel_type: nil)
        super
        @report = report
      end

      def call
        content_tag(:li, link_to(@link_text, report_path))
      end
    end

    class AdvicePageItem < BaseItem
      def initialize(link_text, fuel_types:, school_group:, advice_page:, fuel_type: nil)
        super
        @advice_page = advice_page
      end

      def call
        content_tag(:li, link_to(@link_text,
                                 helpers.advice_page_path(@school_group,
                                                          AdvicePage.find_by_key(@advice_page),
                                                          :analysis,
                                                          anchor: 'comparison')))
      end
    end

    # Reports are keyed on report name, value is link text
    # e.g. { weekday_baseload_variation: 'Weekday variation' }
    class NamedSubList < BaseItem
      def initialize(link_text, fuel_types:, school_group:, reports:, fuel_type: nil)
        super
        @reports = reports
      end

      def call
        content_tag(:li) do
          content_tag(:span, @link_text) +
            content_tag(:ul) do
              content_tag(:li) do
                @reports.map do |report, name|
                  link_to(name, report_path(report))
                end.join(', ').html_safe
              end
            end
        end
      end
    end

    # Reports are keyed on fuel type, links use fuel type as link text,
    # e.g. { electricity: :annual_electricity_use }
    class FuelSubList < BaseItem
      def initialize(link_text, fuel_types:, school_group:, reports:)
        super
        @reports = reports
      end

      def render?
        (@fuel_types & @reports.keys).any?
      end

      def call
        content_tag(:li) do
          content_tag(:span, @link_text) +
            content_tag(:ul) do
              content_tag(:li) do
                (@fuel_types & @reports.keys).map do |fuel_type|
                  config = @reports[fuel_type]
                  if config.is_a?(Hash)
                    link_to(config[:label], report_path(config[:report]))
                  else
                    link_to(t("common.#{fuel_type}"), report_path(config))
                  end
                end.join(', ').html_safe
              end
            end
        end
      end
    end
  end
end
