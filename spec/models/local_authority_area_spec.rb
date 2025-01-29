# frozen_string_literal: true

require 'rails_helper'

describe LocalAuthorityArea do
  describe 'MailchimpUpdateable' do
    subject { create(:local_authority_area) }

    it_behaves_like 'a MailchimpUpdateable'
  end
end
