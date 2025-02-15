# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::HeaderComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:title) { 'Title' }
  let(:all_params) { { id: id, classes: classes, title: title } }


  let(:html) do
    render_inline(Elements::HeaderComponent.new(**params))
  end

  context 'with all params' do
    let(:params) { all_params }

    it { expect(html).to have_css('h1.extra-classes') }
    it { expect(html).to have_css('h1#custom-id') }
    it { expect(html).to have_content('Title') }
  end

  context 'with no classes or id' do
    let(:params) { { title: title } }

    it { expect(html).to have_css('h1') }
    it { expect(html).to have_content('Title') }
  end

  context 'with classes' do
    let(:params) { { title: title, classes: classes } }

    it { expect(html).to have_css('h1.extra-classes') }
    it { expect(html).to have_content('Title') }
  end

  context 'with id' do
    let(:params) { { title: title, id: id } }

    it { expect(html).to have_css('h1#custom-id') }
    it { expect(html).to have_content('Title') }
  end

  context 'with level' do
    let(:params) { { level: 2, title: title } }

    it { expect(html).to have_css('h2') }
  end

  context 'when invalid level' do
    let(:params) { { level: 7, title: title } }

    it { expect { html }.to raise_error(ArgumentError, 'Header level must be between 1 and 6') }
  end
end
