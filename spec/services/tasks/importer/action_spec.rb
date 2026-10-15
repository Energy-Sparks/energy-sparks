# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe Tasks::Importer::Action do
  subject(:importer) { described_class.new(file_name) }

  let(:file_name) { 'actions-categorisations.csv' }
  let!(:intervention_type) { create(:intervention_type, id: 2) }

  let(:rows) do
    [
      Array.new(5),
      Array.new(5),
      Array.new(5), # header row
      build_row(0 => 2, 3 => 'Heating waste, Gas out of hours'),
      build_row(0 => 999)
    ]
  end

  before do
    allow(CSV).to receive(:read).and_return(rows)
    importer.run
  end

  def build_row(values)
    Array.new(5).tap { |row| values.each { |index, value| row[index] = value } }
  end

  def mobility_translation_count
    Mobility::Backends::ActiveRecord::KeyValue::StringTranslation
      .where(translatable_type: Task::Label.name)
      .count
  end

  it 'imports focus labels' do
    expect(intervention_type.focuses.map(&:name)).to contain_exactly('Heating waste', 'Gas out of hours')
  end

  it 'reports the imported intervention type count' do
    expect(importer.imported_count).to eq(1)
  end

  it 'reports the missing intervention types' do
    expect(importer.missing_ids).to eq([999])
  end

  context 'when run again' do
    before { described_class.new(file_name).run }

    it 'does not create duplicate labels' do
      expect(Task::Label.count).to eq(2)
      expect(Task::LabelItem.count).to eq(2)
    end
  end

  describe '.rollback' do
    context 'with the imported categorisations' do
      before { described_class.rollback }

      it 'empties the imported tables', :aggregate_failures do
        expect(Task::LabelItem.count).to be_zero
        expect(Task::Label.count).to be_zero
        expect(mobility_translation_count).to be_zero
      end
    end

    context 'with labels owned by other task importer' do
      let!(:activity_type) { create(:activity_type) }
      let!(:topic_label) { create(:label, label_type: :topic, name: 'Topic') }

      before do
        create(:label_item, task: activity_type, label: topic_label)
        described_class.rollback
      end

      it 'keeps them' do
        expect(activity_type.reload.labels).to contain_exactly(topic_label)
      end
    end
  end
end
