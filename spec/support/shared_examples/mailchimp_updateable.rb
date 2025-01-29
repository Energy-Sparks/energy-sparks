RSpec.shared_examples 'a MailchimpUpdateable' do
  context 'when updated' do
    it 'records updates' do
      double = instance_double(Mailchimp::UpdateCreator)
      expect(Mailchimp::UpdateCreator).to receive(:for).with(subject)
      allow(Mailchimp::UpdateCreator).to receive(:for).with(subject).and_return(double)
      allow(double).to receive(:record_updates).and_return(true)
      subject.touch
    end
  end
end
