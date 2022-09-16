require 'rails_helper'

describe TranslatableAttachment do

  class Dummy < ApplicationRecord
    def self.load_schema!; end

    include TranslatableAttachment

    t_has_one_attached :file
    t_has_one_attached :other

    has_one_attached :normal
  end

  let(:test) { Dummy.new }

  let(:t_attachments) {[:file, :other]}
  let(:attachments) { [:normal] }

  describe "#t_has_one_attached" do
    context "attachment_reflections" do
      subject { test.class.attachment_reflections }

      it "has attachments for each locale" do
        t_attachments.each do |attachment|
          I18n.available_locales.each do |locale|
            expect(subject).to include("#{attachment}_#{locale}")
          end
        end
      end

      it "has non-translated attachments" do
        attachments.each do |attachment|
          expect(subject).to include("#{attachment}")
        end
      end

      it "should contain all attached attributes" do
        expect(subject.count).to eq(t_attachments.count * I18n.available_locales.count + 1)
      end
    end
  end

  describe ".t_attached_attributes" do
    subject { test.class.t_attached_attributes }

    it "returns a list of translated attached attributes" do
      expect(subject).to eq([:file, :other])
    end
  end
end
