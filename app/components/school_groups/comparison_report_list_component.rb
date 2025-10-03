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
      <ul class="comparison-report-list">
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

      # Only render if the item has no fuel type, or the expected fuel type is in the
      # list provided.
      def render?
        @fuel_type.nil? || @fuel_types.include?(@fuel_type)
      end

      def report_exists?(report = @report)
        Comparison::Report.exists?(key: report, public: true)
      end

      def report_path(report = @report)
        helpers.compare_path(group: true, benchmark: report, school_group_ids: [@school_group.id])
      end
    end

    class Item < BaseItem
      def initialize(link_text, fuel_types:, school_group:, report:, fuel_type: nil)
        super
        @report = report
      end

      # Only render if fuel type matches and the report is public
      def render?
        super && report_exists?
      end

      def call
        content_tag(:li, link_to(@link_text, report_path), class: 'single-item')
      end
    end

    # Reports are keyed on report name, value is link text
    # e.g. { weekday_baseload_variation: 'Weekday variation' }
    class NamedSubList < BaseItem
      def initialize(link_text, fuel_types:, school_group:, reports:, fuel_type: nil)
        super
        @reports = reports
      end

      # Only render if fuel type matches and any of the reports are public
      def render?
        super && report_exists?(@reports.keys)
      end

      erb_template <<-ERB
        <li>
          <span><%= @link_text %></span>
          <ul>
            <li>
              <%= comma_separated_links %>
            </li>
          </ul>
        </li>
      ERB

      def comma_separated_links
        @reports.map do |report, name|
          link_to(name, report_path(report))
        end.join(', ').html_safe
      end
    end

    # Reports are keyed on fuel type, links use fuel type as link text,
    # e.g. { electricity: :annual_electricity_use }
    #
    # OR, to allow overriding of labels:
    # e.g. { electricity: { report: :annual_electricity_use, label: 'Some label'} }
    class FuelSubList < BaseItem
      def initialize(link_text, fuel_types:, school_group:, reports:)
        super
        @reports = reports
      end

      # Only render if fuel type matches and any of the reports are public
      # Has to check for both variations of the configuration
      def render?
        return false unless (@fuel_types & @reports.keys).any?
        (@fuel_types & @reports.keys).filter_map do |fuel_type|
          config = @reports[fuel_type]
          if config.is_a?(Hash)
            report_exists?(config[:report])
          else
            report_exists?(config)
          end
        end.any?
      end

      erb_template <<-ERB
        <li>
          <span><%= @link_text %></span>
          <ul>
            <li>
              <%= comma_separated_links %>
            </li>
          </ul>
        </li>
      ERB

      def comma_separated_links
        (@fuel_types & @reports.keys).filter_map do |fuel_type|
          config = @reports[fuel_type]
          if config.is_a?(Hash)
            link_to(config[:label], report_path(config[:report]))
          elsif report_exists?(config)
            link_to(t("common.#{fuel_type}"), report_path(config))
          end
        end.join(', ').html_safe
      end
    end
  end
end
