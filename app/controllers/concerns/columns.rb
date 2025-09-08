# frozen_string_literal: true

module Columns
  extend ActiveSupport::Concern

  private

  class Column
    attr_reader :html_data

    def initialize(name, csv_lambda, td_lambda = nil, display: :csv_and_html, html_data: nil)
      @name = name
      @csv_lambda = csv_lambda
      @td_lambda = td_lambda
      @display = display
      @html_data = html_data
    end

    def name
      if @name.is_a?(Symbol)
        string = @name.to_s
        string.downcase == string ? string.titleize : string
      else
        @name
      end
    end

    def csv(arg)
      @csv_lambda.call(arg)
    end

    def td(arg)
      if @td_lambda&.arity == 2
        @td_lambda.call(arg, csv(arg))
      else
        (@td_lambda || @csv_lambda).call(arg)
      end
    end

    def data_order(arg)
      @csv_lambda.present? ? csv(arg) : ''
    end

    def display_html
      %i[csv_and_html html].include?(@display)
    end

    def display_csv
      %i[csv_and_html csv].include?(@display)
    end
  end

  def csv_report(columns, rows)
    csv_columns = columns.filter(&:display_csv)
    CSV.generate(headers: true) do |csv|
      csv << csv_columns.map(&:name)
      rows.each do |row|
        csv << csv_columns.map { |column| column.csv(row) }
      end
    end
  end
end
