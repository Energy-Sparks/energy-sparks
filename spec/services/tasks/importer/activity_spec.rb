# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe Tasks::Importer::Activity do
  subject(:importer) { described_class.new(file_name) }

  let(:file_name) { 'activities-categorisations-2026-10-15.csv' }
  let!(:activity_type) { create(:activity_type, id: 33) }

  let(:rows) do
    [
      Array.new(29),
      Array.new(29),
      Array.new(29), # three header rows precede the data
      build_row(0 => 33,
                2 => 'Heating, Understanding our energy use',
                3 => 'Improve our knowledge and skills, Adopt energy saving behaviours',
                17 => 'Citizenship, Science',
                18 => 'KS1, KS2, KS3',
                19 => 'Humanities, "Languages, Literacy and Communication", Expressive Arts',
                20 => 'PS 4, PS 3',
                21 => 'social studies, sciences',
                22 => 'First, Second, Third, Fourth, Senior',
                25 => 'Under 30 mins, Half a day, Day or over'),
      build_row(0 => 999)
    ]
  end

  before do
    allow(CSV).to receive(:read).and_return(rows)
    importer.run
  end

  def build_row(values)
    Array.new(29).tap { |row| values.each { |index, value| row[index] = value } }
  end

  def mobility_translation_count
    translated_types = [Task::Label, LearningStage, Activities::SubjectArea].map(&:name)
    Mobility::Backends::ActiveRecord::KeyValue::StringTranslation
      .where(translatable_type: translated_types)
      .count
  end

  it 'imports topic labels' do
    expect(activity_type.topics.map(&:name)).to contain_exactly('Heating', 'Understanding our energy use')
  end

  it 'imports aim labels' do
    expect(activity_type.aims.map(&:name))
      .to contain_exactly('Improve our knowledge and skills', 'Adopt energy saving behaviours')
  end

  it 'imports duration labels' do
    expect(activity_type.durations.map(&:name)).to contain_exactly('Under 30 mins', 'Half a day', 'Day or over')
  end

  it 'imports subject areas' do
    expect(activity_type.subject_areas.map { |area| [area.country, area.name] }).to contain_exactly(
      %w[england Citizenship],
      %w[england Science],
      %w[wales Humanities],
      ['wales', 'Languages, Literacy and Communication'],
      ['wales', 'Expressive Arts'],
      ['scotland', 'social studies'],
      %w[scotland sciences]
    )
  end

  it 'imports learning stages' do
    expect(activity_type.learning_stages.map { |stage| [stage.country, stage.name, stage.abbreviation] })
      .to contain_exactly(
        ['england', 'Key Stage 1', 'KS1'],
        ['england', 'Key Stage 2', 'KS2'],
        ['england', 'Key Stage 3', 'KS3'],
        ['wales', 'Progression Step 3', 'PS3'],
        ['wales', 'Progression Step 4', 'PS4'],
        ['scotland', 'First Level', 'First'],
        ['scotland', 'Second Level', 'Second'],
        ['scotland', 'Third Level', 'Third'],
        ['scotland', 'Fourth Level', 'Fourth'],
        ['scotland', 'Senior Phase', 'Senior']
      )
  end

  it 'reports the imported activity type count' do
    expect(importer.imported_count).to eq(1)
  end

  it 'reports the missing activity types' do
    expect(importer.missing_ids).to eq([999])
  end

  context 'when run again' do
    before { described_class.new(file_name).run }

    it 'does not create duplicate labels' do
      expect(Task::Label.count).to eq(7)
      expect(Task::LabelItem.count).to eq(7)
    end
  end

  describe '.rollback' do
    context 'with the imported categorisations' do
      before { described_class.rollback }

      it 'empties all imported tables', :aggregate_failures do
        expect(Task::LabelItem.count).to be_zero
        expect(Task::Label.count).to be_zero
        expect(Activities::ActivityTypeLearningStage.count).to be_zero
        expect(Activities::ActivityTypeSubjectArea.count).to be_zero
        expect(LearningStage.count).to be_zero
        expect(Activities::SubjectArea.count).to be_zero
        expect(mobility_translation_count).to be_zero
      end
    end

    context 'with labels owned by other task importer' do
      let!(:intervention_type) { create(:intervention_type) }
      let!(:focus_label) { create(:label, label_type: :focus, name: 'Focus') }

      before do
        create(:label_item, task: intervention_type, label: focus_label)
        described_class.rollback
      end

      it 'keeps them' do
        expect(intervention_type.reload.labels).to contain_exactly(focus_label)
      end
    end
  end
end
