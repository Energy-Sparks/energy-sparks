# frozen_string_literal: true

# Imports focus labels for actions (intervention types) from a CSV exported from:
# https://docs.google.com/spreadsheets/d/1GmCHb0PFWvaF2_cAaUlLzOyx6vkNPj0ilAiT7JDfugA/edit?usp=sharing
# This was last exported on 15/10/2026 and stored in lib/tasks/deployment/actions-categorisations-2026-10-15.csv

module Tasks
  module Importer
    class Action < Base
      START_ROW = 3

      COLUMNS = {
        intervention_type_id: 0,
        focus: 3
      }.freeze

      LABEL_COLUMNS = {
        focus: :focus
      }.freeze

      def self.rollback
        ActiveRecord::Base.transaction do
          Task::LabelItem.where(task_type: InterventionType.name).delete_all
          Task::Label.where.missing(:label_items).destroy_all
        end
      end

      private

      def import_row(row)
        intervention_type = InterventionType.find_by(id: row[COLUMNS[:intervention_type_id]].to_i)

        unless intervention_type
          @missing_ids << row[COLUMNS[:intervention_type_id]]
          return
        end

        import_labels(row, intervention_type)

        @imported_count += 1
      end
    end
  end
end
