# frozen_string_literal: true

require 'csv'

module Tasks
  module Importer
    class Base
      START_ROW = 2

      def self.rollback
        raise NotImplementedError, "#{self} must implement .rollback"
      end

      attr_reader :imported_count, :missing_ids

      def initialize(file_path)
        @file_path = file_path
        @imported_count = 0
        @missing_ids = []
      end

      def run
        rows.each { |row| import_row(row) }
        self
      end

      private

      def rows
        CSV.read(@file_path).drop(self.class::START_ROW)
      end

      def import_row(_row)
        raise NotImplementedError, "#{self.class} must implement #import_row"
      end

      def import_labels(row, task)
        self.class::LABEL_COLUMNS.each do |column, label_type|
          split_values(row[self.class::COLUMNS[column]]).each do |name|
            label = find_or_create_label(label_type, name)
            Task::LabelItem.find_or_create_by!(task_type: task.class.name, task_id: task.id, label:)
          end
        end
      end

      def find_or_create_label(label_type, name)
        Task::Label.where(label_type:).detect { |label| label.name == name } ||
          Task::Label.create!(label_type:, name:)
      end

      def split_values(value)
        return [] if value.blank?

        CSV.parse_line(value.gsub(/,\s*"/, ',"')).map(&:strip).compact_blank
      end
    end
  end
end
