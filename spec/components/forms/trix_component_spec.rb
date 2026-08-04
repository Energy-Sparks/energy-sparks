# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Forms::TrixComponent, :include_application_helper, type: :component do
  subject(:component) { described_class.new(**params, **kwargs) }

  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:kwargs) { { id: id, classes: classes } }
  let(:form) { SimpleForm::FormBuilder.new(:activity, Activity.new, vc_test_controller.view_context, {}) }
  let(:field) { :description }
  let(:params) { { form:, field: } }

  def render = render_inline(component)

  context 'when rendering' do
    context 'with base params' do
      before { render }

      it_behaves_like 'an application component' do
        let(:expected_classes) { classes }
        let(:expected_id) { id }
      end
    end

    it 'has a trix editor' do
      render
      expect(page).to have_css('trix-editor.rich_text_area')
    end

    context 'with size' do
      let(:params) { { form:, field:, size: } }

      context 'when the style is recognised' do
        let(:size) { :default }

        before { render }

        it { expect(page).to have_css('div.forms-trix-component.default') }
      end

      context 'when the style is unrecognised' do
        let(:size) { :notgood }

        it { expect { render }.to raise_error(ArgumentError, 'Unknown size') }
      end
    end

    context 'with controls' do
      let(:params) { { form:, field:, controls: } }

      context 'when the style is recognised' do
        let(:controls) { :default }

        before { render }

        it { expect(page).to have_css('div.forms-trix-component.controls-default') }
      end

      context 'when the style is unrecognised' do
        let(:controls) { :notgood }

        it { expect { render }.to raise_error(ArgumentError, 'Unknown controls options') }
      end
    end

    context 'with button size' do
      let(:params) { { form:, field:, button_size: size } }

      context 'when the style is recognised' do
        let(:size) { :default }

        before { render }

        it { expect(page).to have_css('div.forms-trix-component.buttons-default') }
      end

      context 'when the style is unrecognised' do
        let(:size) { :notgood }

        it { expect { render }.to raise_error(ArgumentError, 'Unknown button size') }
      end
    end

    context 'with charts' do
      let(:params) { { form:, field:, charts: [['Examples', :chart_identifier]] } }

      before { render }

      it 'adds data attribute' do
        expect(page).to have_css('.forms-trix-component[data-chart-list]')
      end
    end
  end
end
