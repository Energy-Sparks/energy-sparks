# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Forms::TrixComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:kwargs) { { id: id, classes: classes } }

  # rubocop:disable RSpec/VerifiedDoubles
  # disabling as real method has extra default parameter, so can't easily stub
  # just want to confirm that the rich_text_area helper is called
  let(:form) { double(ActionView::Helpers::FormHelper) }
  # rubocop:enable RSpec/VerifiedDoubles

  let(:field) { :description }

  let(:params) do
    { form: form, field: field }
  end

  subject(:component) { described_class.new(**params, **kwargs) }

  context 'when rendering' do
    let(:html) { render_inline(component) }

    before do
      allow(form).to receive(:rich_text_area)
    end

    context 'with base params' do
      it_behaves_like 'an application component' do
        let(:expected_classes) { classes }
        let(:expected_id) { id }
      end
    end

    it 'adds rich_text_area' do
      html
      expect(form).to have_received(:rich_text_area).with(field)
    end

    context 'with size' do
      let(:params) do
        { form: form, field: field, size: size }
      end

      context 'when the style is recognised' do
        let(:size) { :default }

        it { expect(html).to have_css('div.forms-trix-component.default') }
      end

      context 'when the style is unrecognised' do
        let(:size) { :notgood }

        it { expect { html }.to raise_error(ArgumentError, 'Unknown size') }
      end
    end

    context 'with controls' do
      let(:params) do
        { form: form, field: field, controls: controls }
      end

      context 'when the style is recognised' do
        let(:controls) { :default }

        it { expect(html).to have_css('div.forms-trix-component.controls-default') }
      end

      context 'when the style is unrecognised' do
        let(:controls) { :notgood }

        it { expect { html }.to raise_error(ArgumentError, 'Unknown controls options') }
      end
    end

    context 'with button size' do
      let(:params) do
        { form: form, field: field, button_size: size }
      end

      context 'when the style is recognised' do
        let(:size) { :default }

        it { expect(html).to have_css('div.forms-trix-component.buttons-default') }
      end

      context 'when the style is unrecognised' do
        let(:size) { :notgood }

        it { expect { html }.to raise_error(ArgumentError, 'Unknown button size') }
      end
    end

    context 'with charts' do
      let(:params) do
        { form: form, field: field, charts: [['Examples', :chart_identifier]] }
      end

      it 'adds data attribute' do
        expect(html).to have_css('.forms-trix-component[data-chart-list]')
      end
    end
  end
end
