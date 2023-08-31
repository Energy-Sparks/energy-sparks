require "rails_helper"

RSpec.describe ApplicationController, type: :controller do

  let(:user) { create(:user) }

  describe "#after_sign_in_path_for" do
    it "redirects to the root path" do
      expect(subject.after_sign_in_path_for(user)).to eq('http://test.host/')
    end

    it "uses the return to url" do
      allow_any_instance_of(ApplicationController).to receive(:session).and_return({user_return_to: '/blah'})
      expect(subject.after_sign_in_path_for(user)).to eq('/blah')
    end

    context 'when redirecting to prefered locale' do
      let(:user) { create(:user, preferred_locale: :cy) }

      it "redirects to the root path for locale" do
        expect(subject.after_sign_in_path_for(user)).to eq('http://cy.test.host/')
      end

      it "uses the return to url and locale subdomain" do
        allow_any_instance_of(ApplicationController).to receive(:session).and_return({user_return_to: '/blah'})
        expect(subject.after_sign_in_path_for(user)).to eq('http://cy.test.host/blah')
      end
    end
  end
end
