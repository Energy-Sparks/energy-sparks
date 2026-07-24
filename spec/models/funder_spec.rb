# frozen_string_literal: true

require 'rails_helper'

describe Funder do
  describe 'MailchimpUpdateable' do
    subject(:funder) { create(:funder) }

    it_behaves_like 'a MailchimpUpdateable' do
      let(:mailchimp_field_changes) do
        {
          name: 'New name'
        }
      end
    end
  end
end
