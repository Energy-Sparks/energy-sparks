require 'rails_helper'

describe IssuesHelper do
  describe '.issue_type_icon' do
    context 'count is specified' do
      subject { helper.issue_type_icon(issue_type, count) }

      context 'for note' do
        let(:issue_type) { :note }

        context 'when count is > 0' do
          let(:count) { 3 }

          it { expect(subject).to have_css('i.fa-sticky-note.text-warning') }
        end

        context 'when count is 0' do
          let(:count) { 0 }

          it { expect(subject).to have_css('i.fa-sticky-note') }
          it { expect(subject).not_to have_css('i.fa-sticky-note.text-warning') }
        end
      end

      context 'for issue' do
        let(:issue_type) { :issue }

        context 'when count is > 0' do
          let(:count) { 3 }

          it { expect(subject).to have_css('i.fa-exclamation-circle.text-danger') }
        end

        context 'when count is 0' do
          let(:count) { 0 }

          it { expect(subject).to have_css('i.fa-exclamation-circle') }
          it { expect(subject).not_to have_css('i.fa-exclamation-circle.text-danger') }
        end
      end
    end
  end

  describe '.issue_type_icons' do
    let(:school) { create(:school) }
    let(:note) { create(:issue, issue_type: :note) }
    let(:issue) { create(:issue, issue_type: :issue) }

    subject { helper.issue_type_icons(school.issues, hide_empty: hide_empty) }

    context 'showing icons when no issues of type present' do
      let(:hide_empty) { false }

      it { expect(subject).not_to have_css('i.fa-sticky-note.text-warning') }
      it { expect(subject).not_to have_css('i.fa-exclamation-circle.text-danger') }
      it { expect(subject).to have_css("span[title='0 issues & 0 notes']") }

      context 'issues includes a note' do
        before { school.issues << note }

        it { expect(subject).to have_css('i.fa-sticky-note.text-warning') }
        it { expect(subject).not_to have_css('i.fa-exclamation-circle.text-danger') }
        it { expect(subject).to have_css("span[title='0 issues & 1 note']") }
      end

      context 'issues includes an issue' do
        before { school.issues << issue }

        it { expect(subject).not_to have_css('i.fa-sticky-note.text-warning') }
        it { expect(subject).to have_css('i.fa-exclamation-circle.text-danger') }
        it { expect(subject).to have_css("span[title='1 issue & 0 notes']") }
      end
    end

    context 'hiding when no issues of type present' do
      let(:hide_empty) { true }

      it { expect(subject).not_to have_css('i.fa-sticky-note') }
      it { expect(subject).not_to have_css('i.fa-exclamation-circle') }
      it { expect(subject).not_to have_css('span') }

      context 'issues includes a note' do
        before { school.issues << note }

        it { expect(subject).to have_css('i.fa-sticky-note.text-warning') }
        it { expect(subject).not_to have_css('i.fa-exclamation-circle') }
        it { expect(subject).to have_css("span[title='1 note']") }
      end

      context 'issues includes an issue' do
        before { school.issues << issue }

        it { expect(subject).not_to have_css('i.fa-sticky-note') }
        it { expect(subject).to have_css('i.fa-exclamation-circle.text-danger') }
        it { expect(subject).to have_css("span[title='1 issue']") }
      end
    end
  end

  describe '.issue_type_image' do
    subject { helper.issue_type_image(issue_type) }

    context 'for note' do
      let(:issue_type) { :note }

      it { expect(subject).to include('email/sticky-note-regular') }
    end

    context 'for issue' do
      let(:issue_type) { :issue }

      it { expect(subject).to include('email/exclamation-circle-solid') }
    end
  end
end
