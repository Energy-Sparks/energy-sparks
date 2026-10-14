# frozen_string_literal: true

module Tasks
  module Importer
    # Imports the classification spreadsheet that categorises activities by
    # topic, aim, duration, subject area and learning stage. Used by the
    # after_party:import_activity_categorisations deployment task
    class Activity < Base
      DATA_START_ROW = 3

      COLUMNS = {
        activity_type_id: 0,
        topic: 2,
        aim: 3,
        english_subject: 17,
        english_key_stage: 18,
        welsh_aole: 19,
        welsh_progression_step: 20,
        scottish_curriculum_area: 21,
        scottish_level: 22,
        duration: 25
      }.freeze

      LABEL_COLUMNS = {
        topic: :topic,
        aim: :aim,
        duration: :duration
      }.freeze

      SUBJECT_AREA_COLUMNS = {
        english_subject: :england,
        welsh_aole: :wales,
        scottish_curriculum_area: :scotland
      }.freeze

      LEARNING_STAGE_COLUMNS = {
        english_key_stage: :england,
        welsh_progression_step: :wales,
        scottish_level: :scotland
      }.freeze

      def self.rollback
        ActiveRecord::Base.transaction do
          Task::LabelItem.where(task_type: ActivityType.name).delete_all
          Activities::ActivityTypeLearningStage.delete_all
          Activities::ActivityTypeSubjectArea.delete_all

          Task::Label.where.missing(:label_items).destroy_all
          LearningStage.destroy_all
          Activities::SubjectArea.destroy_all
        end
      end

      private

      def import_row(row)
        activity_type = ActivityType.find_by(id: row[COLUMNS[:activity_type_id]].to_i)

        unless activity_type
          @missing_ids << row[COLUMNS[:activity_type_id]]
          return
        end

        import_labels(row, activity_type)
        import_subject_areas(row, activity_type)
        import_learning_stages(row, activity_type)

        @imported_count += 1
      end

      def import_subject_areas(row, activity_type)
        SUBJECT_AREA_COLUMNS.each do |column, country|
          split_values(row[COLUMNS[column]]).each do |name|
            subject_area = find_or_create_subject_area(country, name)
            Activities::ActivityTypeSubjectArea.find_or_create_by!(
              activity_type:, subject_area:
            )
          end
        end
      end

      def import_learning_stages(row, activity_type)
        LEARNING_STAGE_COLUMNS.each do |column, country|
          split_values(row[COLUMNS[column]]).each do |code|
            learning_stage = find_or_create_learning_stage(country, code)
            Activities::ActivityTypeLearningStage.find_or_create_by!(
              activity_type:, learning_stage:
            )
          end
        end
      end

      def find_or_create_subject_area(country, name)
        Activities::SubjectArea.where(country:).detect { |area| area.name == name } ||
          Activities::SubjectArea.create!(country:, name:)
      end

      def find_or_create_learning_stage(country, code)
        name, abbreviation = learning_stage_name_and_abbreviation(country, code)
        LearningStage.where(country:).detect { |stage| stage.name == name } ||
          LearningStage.create!(country:, name:, abbreviation:)
      end

      def learning_stage_name_and_abbreviation(country, code)
        case country.to_sym
        when :england
          number = code.sub(/\AKS\s*/i, '')
          ["Key Stage #{number}", "KS#{number}"]
        when :wales
          number = code.sub(/\APS\s*/i, '')
          ["Progression Step #{number}", "PS#{number}"]
        when :scotland
          [code == 'Senior' ? 'Senior Phase' : "#{code} Level", code]
        else
          [code, code]
        end
      end
    end
  end
end
