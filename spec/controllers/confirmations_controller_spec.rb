# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConfirmationsController, type: :controller do
  include Rails.application.routes.url_helpers

  describe '#show' do
    let(:user) { create(:user, confirmed_at: nil) }
    let(:token) { user.confirmation_token }

    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
      user.send_confirmation_instructions
    end

    context 'with HEAD' do
      before do
        head :show, params: { confirmation_token: token }
      end

      it 'does not redirect' do
        expect(response).to be_successful
      end

      it 'does not confirm the user' do
        expect(user.reload.confirmed?).to be(false)
      end
    end

    context 'with GET' do
      before do
        get :show, params: { confirmation_token: token }
      end

      it 'redirects' do
        uri = URI.parse(response.location)
        params = Rack::Utils.parse_nested_query(uri.query)

        expect(uri.path).to eq('/users/password/edit')
        expect(params).to include('confirmed' => 'true')
        expect(params).to include('reset_password_token' => a_string_matching(/\A.+\z/))
      end

      it 'confirms the user' do
        expect(user.reload.confirmed?).to be(true)
      end
    end
  end
end
