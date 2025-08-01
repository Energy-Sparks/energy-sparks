# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cms::AudienceComponent, :include_application_helper, :include_url_helpers, type: :component do
  let(:current_user) { create(:school_admin) }
  let(:audience) { :anyone }

  let(:params) do
    {
      id: 'custom-id',
      classes: 'extra-classes',
      page: create(:page, :with_sections, audience: audience, sections_published: true, published: true),
      current_user: current_user
    }
  end

  let(:html) do
    render_inline(described_class.new(**params))
  end

  context 'with base params' do
    it_behaves_like 'an application component' do
      let(:expected_classes) { params[:classes] }
      let(:expected_id) { params[:id] }
    end

    it { expect(html).to have_content(I18n.t('components.cms.audience.title')) }

    context 'when audience is anyone' do
      it 'summarises the audience' do
        expect(html).to have_content('This page provides help for anyone using the Energy Sparks website')
      end
    end

    context 'when audience is school users' do
      let(:audience) { :school_users }

      it 'summarises the audience' do
        expect(html).to have_content('This page provides help for all registered school users')
      end

      it 'confirms the user' do
        expect(html).to have_content('You are currently signed in as a School admin')
      end

      context 'with no user' do
        let(:current_user) { nil }

        it 'prompts to login' do
          expect(html).to have_link('sign-in', href: new_user_session_path)
        end
      end
    end

    context 'when audience is school admins' do
      let(:audience) { :school_admins }

      it 'summarises the audience' do
        expect(html).to have_content('This page provides help for School and Group admins')
      end

      context 'with only staff user' do
        let(:current_user) { create(:staff) }

        it 'says they wont have permission' do
          expect(html).to have_content('This page provides help for School and Group admins')
        end
      end
    end

    context 'when audience is group admins' do
      let(:audience) { :group_admins }

      it 'summarises the audience' do
        expect(html).to have_content('This page provides help for Group admins')
      end
    end
  end
end
