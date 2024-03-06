# frozen_string_literal: true

module Comparisons
  class BaseloadPerPupilController < BaseController

    def index
      super
      @table = Table.new
    end

    private

    def key
      :baseload_per_pupil
    end

    def advice_page_key
      :baseload
    end

    def load_data
      Comparison::BaseloadPerPupil.where(school: @schools).where.not(one_year_baseload_per_pupil_kw: nil).order(one_year_baseload_per_pupil_kw: :desc)
    end

    def create_charts(results)
      create_single_number_chart(results, :one_year_baseload_per_pupil_kw, 1000.0, 'baseload_per_pupil_w', 'w')
    end

    class Table
      def columns
        [School, BaseloadPerPupil, LastYearCostOfBaseload, AverageBaseloadKw, BaseloadPercent, SavingIfMatchedExemplarSchool]
      end

      class Column
        include AdvicePageHelper
        delegate :helpers, to: ActionController::Base
        # delegate :url_helpers, to: 'Rails.application.routes'
      end

      class School < Column
        def header
          :school
        end

        def html(result, advice_page)
          # s = helpers.link_to(result.school.name, Rails.application.routes.url_helpers.advice_page_path(result.school, advice_page, :insights))
          s = helpers.link_to(result.school.name, '')
          if result.electricity_economic_tariff_changed_this_year
            s << ' <a href="#electricity_economic_tariff_changed_this_year">[t]</a>'.html_safe
          end
          s
        end
      end

      class BaseloadPerPupil < Column
        def header
          :baseload_per_pupil_w
        end

        def html(result, _advice_page)
          format_unit(result.one_year_baseload_per_pupil_kw * 1000.0, :kw, true, :benchmark)
        end
      end

      class LastYearCostOfBaseload < Column
        def header
          :last_year_cost_of_baseload
        end

        def html(result, _advice_page)
          format_unit(result.average_baseload_last_year_gbp, :£, true, :benchmark)
        end
      end

      class AverageBaseloadKw < Column
        def header
          :average_baseload_kw
        end

        def html(result, _advice_page)
          format_unit(result.average_baseload_last_year_kw, :kw, true, :benchmark)
        end
      end

      class BaseloadPercent < Column
        def header
          :baseload_percent
        end

        def html(result, _advice_page)
          format_unit(result.annual_baseload_percent, :percent, true, :benchmark)
        end
      end

      class SavingIfMatchedExemplarSchool < Column
        def header
          :saving_if_matched_exemplar_school
        end

        def html(result, _advice_page)
          format_unit([0.0, result.one_year_saving_versus_exemplar_gbp].max, :£, true, :benchmark)
        end
      end

    end

  end
end
