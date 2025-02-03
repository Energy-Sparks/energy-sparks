RSpec.shared_examples 'a MailchimpUpdateable' do
  let(:mailchimp_field_changes) { {} }
  let(:ignored_field_changes) { {} }

  context 'when included' do
    it 'defines some fields to monitor' do
      expect(subject.class.mailchimp_fields).not_to be_empty
    end
  end

  context 'when not changed' do
    it 'does nothing by default' do
      subject.save!
      expect(subject.mailchimp_fields_changed_at_previously_changed?).to be(false)
    end
  end

  context 'when updated' do
    def expect_changes_for(changes, changed)
      changes.each_pair do |change|
        subject.update!(change[0] => change[1])
        expect(subject.mailchimp_fields_changed_at_previously_changed?).to be(changed)
        subject.reload
      end
    end

    context 'when ignores fields are changed' do
      it 'does not change the timestamp' do
        expect_changes_for(ignored_field_changes, false)
      end
    end

    context 'when mailchimp fields are updated' do
      it 'updates the timestamp' do
        expect_changes_for(mailchimp_field_changes, true)
      end
    end
  end
end
