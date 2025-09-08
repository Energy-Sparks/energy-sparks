require 'rails_helper'

RSpec.describe Testimonial, type: :model do
  describe 'validations' do
    context 'with valid attributes' do
      subject(:testimonial) { create(:testimonial) }

      it { expect(testimonial).to be_valid }
      it { expect(testimonial).to validate_presence_of(:image) }
      it { expect(testimonial).to validate_presence_of(:title_en) }
      it { expect(testimonial).to validate_presence_of(:name) }
      it { expect(testimonial).to validate_presence_of(:quote_en) }
      it { expect(testimonial).to validate_presence_of(:organisation) }
      it { expect(testimonial).to validate_presence_of(:category) }
    end
  end

  describe 'associations' do
    subject(:testimonial) { create(:testimonial) }

    it { expect(testimonial).to belong_to(:case_study).optional }
    it { expect(testimonial).to have_one_attached(:image) }
  end

  describe 'scopes' do
    describe '.active' do
      let!(:active_testimonial) { create(:testimonial, active: true) }
      let!(:inactive_testimonial) { create(:testimonial, active: false) }

      it 'includes only active testimonials' do
        expect(Testimonial.active).to include(active_testimonial)
        expect(Testimonial.active).not_to include(inactive_testimonial)
      end
    end
  end

  describe 'translations' do
    let!(:testimonial) do
      create(
        :testimonial,
        title_en: 'English Title',
        title_cy: 'Welsh Title',
        quote_en: 'English Quote',
        quote_cy: 'Welsh Quote',
        role_en: 'English Role',
        role_cy: 'Welsh Role'
      )
    end

    context 'when locale is English' do
      around do |example|
        I18n.with_locale(:en) { example.run }
      end

      it 'returns English translations' do
        expect(testimonial.title).to eq('English Title')
        expect(testimonial.quote).to eq('English Quote')
        expect(testimonial.role).to eq('English Role')
      end
    end

    context 'when locale is Welsh' do
      around do |example|
        I18n.with_locale(:cy) { example.run }
      end

      it 'returns Welsh translations' do
        expect(testimonial.title).to eq('Welsh Title')
        expect(testimonial.quote).to eq('Welsh Quote')
        expect(testimonial.role).to eq('Welsh Role')
      end
    end

    context 'when locale is Welsh but no Welsh translation exists' do
      let!(:testimonial) { create(:testimonial, title_cy: nil, quote_cy: nil, role_cy: nil) }

      around do |example|
        I18n.with_locale(:cy) { example.run }
      end

      it 'falls back to English' do
        expect(testimonial.title).to eq(testimonial.title_en)
        expect(testimonial.quote).to eq(testimonial.quote_en)
        expect(testimonial.role).to eq(testimonial.role_en)
      end
    end
  end
end
