require 'rails_helper'

describe TranslatableAttachment do
  class TranslatableDummy < ApplicationRecord
    def self.load_schema!; end

    include TranslatableAttachment

    t_has_one_attached :file
    t_has_one_attached :other

    has_one_attached :normal
  end

  let(:test) { TranslatableDummy.new }

  let(:t_attachments) { %i[file other] }
  let(:attachments) { [:normal] }

  describe '.t_has_one_attached' do
    context 'attachment_reflections' do
      subject { test.class.attachment_reflections }

      it 'has attachments for each locale' do
        t_attachments.each do |attachment|
          I18n.available_locales.each do |locale|
            expect(subject).to include("#{attachment}_#{locale}")
          end
        end
      end

      it 'has non-translated attachments' do
        attachments.each do |attachment|
          expect(subject).to include(attachment.to_s)
        end
      end

      it 'contains all attached attributes' do
        expect(subject.count).to eq(t_attachments.count * I18n.available_locales.count + 1)
      end
    end
  end

  describe '.t_attached_attributes' do
    subject { test.class.t_attached_attributes }

    it 'returns a list of translated attached attributes' do
      expect(subject).to eq(%i[file other])
    end
  end

  describe '#t_attached_or_default' do
    let(:attachment) { { io: File.open(Rails.root.join('spec', 'fixtures', 'images', 'sheffield.png')), filename: 'sheffield.png', content_type: 'image/png' } }

    after do
      I18n.locale = :en
      I18n.default_locale = :en
    end

    context 'when current locale is default' do
      before do
        I18n.locale = :en
        I18n.default_locale = :en
      end

      context 'when specified locale file is attached' do
        before { test.file_cy.attach(**attachment) }

        it 'serves default locale file' do
          expect(test.t_attached_or_default(:file, :cy).name).to eq('file_cy')
        end
      end

      context 'when only default locale file attached' do
        before { test.file_en.attach(**attachment) }

        it 'serves default locale file' do
          expect(test.t_attached_or_default(:file, :cy).name).to eq('file_en')
        end

        it 'serves current locale file by default' do
          expect(test.t_attached_or_default(:file).name).to eq('file_en')
        end
      end

      context 'when only other locale file attached' do
        before { test.file_cy.attach(**attachment) }

        it { expect(test.t_attached_or_default(:file, :en)).to be_nil }
        it { expect(test.t_attached_or_default(:file)).to be_nil }
      end

      context 'when both locale files are attached' do
        before do
          test.file_cy.attach(**attachment)
          test.file_en.attach(**attachment)
        end

        it 'serves specified locale file' do
          expect(test.t_attached_or_default(:file, :cy).name).to eq('file_cy')
        end

        it 'serves current locale file by default' do
          expect(test.t_attached_or_default(:file).name).to eq('file_en')
        end
      end

      context 'when no files are attached' do
        it { expect(test.t_attached_or_default(:file)).to be_nil }
        it { expect(test.t_attached_or_default(:file, :cy)).to be_nil }
        it { expect(test.t_attached_or_default(:file, :en)).to be_nil }
      end
    end
  end
end
