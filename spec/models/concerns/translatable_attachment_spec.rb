# frozen_string_literal: true

require 'rails_helper'

describe TranslatableAttachment do
  class TranslatableDummy < ApplicationRecord
    establish_connection(adapter: 'sqlite3', database: ':memory:')
    connection.create_table(:translatable_dummies)

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
      subject(:attachment_reflections) { test.class.attachment_reflections }

      it 'has attachments for each locale' do
        t_attachments.each do |attachment|
          I18n.available_locales.each do |locale|
            expect(attachment_reflections).to include("#{attachment}_#{locale}")
          end
        end
      end

      it 'has non-translated attachments' do
        attachments.each do |attachment|
          expect(attachment_reflections).to include(attachment.to_s)
        end
      end

      it 'contains all attached attributes' do
        expect(attachment_reflections.count).to eq((t_attachments.count * I18n.available_locales.count) + 1)
      end
    end
  end

  describe '.t_attached_attributes' do
    it 'returns a list of translated attached attributes' do
      expect(test.class.t_attached_attributes).to eq(%i[file other])
    end
  end

  describe '#t_attached_or_default' do
    let(:attachment) do
      { io: Rails.root.join('spec/fixtures/images/sheffield.png').open, filename: 'sheffield.png',
        content_type: 'image/png' }
    end

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

        context 'when placeholder is provided' do
          it { expect(test.t_attached_or_default(:file, placeholder: 'placeholder')).to eq('placeholder') }
        end
      end
    end
  end
end
