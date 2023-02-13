# rubocop:disable Naming/AsciiIdentifiers
module AdvicePageHelper
  def advice_page_path(school, advice_page, tab = :insights)
    polymorphic_path([tab, school, :advice, advice_page.key.to_sym])
  end

  def chart_start_month_year(date = Time.zone.today)
    month_year(date.last_month - 1.year)
  end

  def chart_end_month_year(date = Time.zone.today)
    month_year(date.last_month)
  end

  def month_year(date)
    I18n.t('date.month_names')[date.month] + " " + date.year.to_s
  end

  def advice_baseload_high?(estimated_savings_vs_benchmark)
    estimated_savings_vs_benchmark > 0.0
  end

  def format_rating(rating)
    rating > 4 ? "Limited variation" : "Large variation"
  end

  #link to a specific benchmark for a school group, falls back to the
  #generic benchmark page if a school doesn't have a group
  def benchmark_for_school_group_path(benchmark_type, school)
    if school.school_group.present?
      benchmark_path({ "benchmark_type" => benchmark_type, "benchmark[school_group_ids][]" => school.school_group.id })
    else
      benchmark_path({ "benchmark_type" => benchmark_type })
    end
  end

  #categorise a school as being in the "exemplar", "benchmark" or "other" categories
  #by comparing a numeric metric, e.g. their baseload, against expected values for
  #the other categories
  #
  #returns a symbol: :exemplar, :benchmark, :other
  def categorise_school_vs_benchmark(school, benchmark_school, exemplar_school)
    return :other if school.nil? || benchmark_school.nil? || exemplar_school.nil?
    if school <= exemplar_school
      :exemplar
    elsif school > exemplar_school &&
          school <= benchmark_school
      :benchmark
    else
      :other
    end
  end

  def row_class_for_category(category, compare, row_class = 'positive-row')
    row_class if category == compare
  end

  #calculate relative % change of a current value from a base value
  def relative_percent(base, current)
    return 0.0 if base.nil? || current.nil? || base == current
    return 0.0 if base == 0.0
    (current - base) / base
  end

  def recent_data?(end_date)
    end_date > (Time.zone.today - 30.days)
  end

  def one_years_data?(start_date, end_date)
    (end_date - 364) >= start_date
  end

  def months_analysed(start_date, end_date)
    months = months_between(start_date, end_date)
    months > 12 ? 12 : months
  end

  def months_between(start_date, end_date)
    ((end_date - start_date).to_f / 365 * 12).round
  end

  def annual_usage_breakdown_totals_for(annual_usage_breakdown, unit = :kwh)
    annual_usage_breakdown.holiday.send(unit) +
      annual_usage_breakdown.weekend.send(unit) +
      annual_usage_breakdown.school_day_open.send(unit) +
      annual_usage_breakdown.school_day_closed.send(unit) +
      annual_usage_breakdown.community.send(unit)
  end

  def meters_by_estimated_saving(meters)
    meters.sort_by {|_, v| -v.estimated_saving_£ }
  end

  def meters_by_percentage_baseload(meters)
    meters.sort_by {|_, v| -v.percentage_baseload }
  end
end
# rubocop:enable Naming/AsciiIdentifiers
