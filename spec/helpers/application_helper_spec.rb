require 'rails_helper'

describe ApplicationHelper do

  describe '.up_downify' do

    it 'adds an up arrow icon for positive starts' do
      expect(helper.up_downify('+10%')).to include('<i')
      expect(helper.up_downify('+10%')).to include('up')
    end

    it 'adds an up arrow icon for increased' do
      expect(helper.up_downify('increased')).to include('<i')
      expect(helper.up_downify('increased')).to include('up')
    end

    it 'adds a down arrow icon for negative starts' do
      expect(helper.up_downify('-10%')).to include('<i')
      expect(helper.up_downify('-10%')).to include('down')
    end

    it 'adds a down arrow icon for decreased' do
      expect(helper.up_downify('decreased')).to include('<i')
      expect(helper.up_downify('decreased')).to include('down')
    end

    it 'does not add other strings' do
      expect(helper.up_downify('hello')).to_not include('<i')
      expect(helper.up_downify('hello + goodbye')).to_not include('<i')
    end

  end

  describe 'last signed in helper' do
    it 'shows a message if a user has never signed in' do
      expect(display_last_signed_in_as(build(:user))).to eq 'Never signed in'
    end

    it 'shows the last time as user signed in' do
      last_sign_in_at = DateTime.new(2001,2,3,4,5,6)
      expect(display_last_signed_in_as(build(:user, last_sign_in_at: last_sign_in_at))).to eq nice_date_times(last_sign_in_at)
    end
  end

  describe 'other_field_name' do
    it 'makes a name from wordy category title' do
      expect(helper.other_field_name('Local authority')).to eq('OTHER_LA')
    end
    it 'makes a name from abbreviated category title' do
      expect(helper.other_field_name('MAT')).to eq('OTHER_MAT')
    end
  end

  describe 'human_counts' do
    it 'shows 0 as once' do
      expect(helper.human_counts([])).to eq('no times')
    end
    it 'shows 1 as once' do
      expect(helper.human_counts([1])).to eq('once')
    end
    it 'shows 2 as twice' do
      expect(helper.human_counts([1,2])).to eq('twice')
    end
    it 'shows more than 2 as several times' do
      expect(helper.human_counts([1,2,3])).to eq('several times')
    end
  end

  describe 'progress_as_percent' do
    it 'formats as percent' do
      expect(helper.progress_as_percent(10, 100)).to eq('10 %')
    end
    it 'to 0 dp' do
      expect(helper.progress_as_percent(1, 3)).to eq('33 %')
    end
    it 'handles overachievment' do
      expect(helper.progress_as_percent(110, 100)).to eq('100 %')
    end
    it 'handles non-numbers' do
      expect(helper.progress_as_percent('foo', 'bar')).to eq(nil)
    end
    it 'handles divide by zero' do
      expect(helper.progress_as_percent(10, 0)).to eq(nil)
    end
  end

  describe 'add_or_remove' do
    it 'adds item when empty' do
      expect(helper.add_or_remove(nil, 'KS1')).to eq('KS1')
    end
    it 'adds item to list' do
      expect(helper.add_or_remove('KS1,KS2', 'KS3')).to eq('KS1,KS2,KS3')
    end
    it 'handles whitespace' do
      expect(helper.add_or_remove(' KS1   , KS2', 'KS3')).to eq('KS1,KS2,KS3')
    end
    it 'removes item from list' do
      expect(helper.add_or_remove('KS1,KS2,KS3', 'KS2')).to eq('KS1,KS3')
    end
  end

  describe 'activity_types_badge_class' do
    it 'has the non-selected class' do
      expect(helper.activity_types_badge_class('KS1, KS2', 'KS3', 'info')).to include('badge-light')
    end
    it 'has the selected class' do
      expect(helper.activity_types_badge_class('KS1, KS2', 'KS1', 'info')).to include('badge-info')
    end
  end

  describe '.file_type_icon' do
    it 'renders a spreadsheet icon' do
      expect(helper.file_type_icon('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')).to include('<i')
      expect(helper.file_type_icon('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')).to include('file-excel')
    end
    it 'renders a doc icon' do
      expect(helper.file_type_icon('application/vnd.openxmlformats-officedocument.wordprocessingml.document')).to include('<i')
      expect(helper.file_type_icon('application/vnd.openxmlformats-officedocument.wordprocessingml.document')).to include('file-word')
    end
    it 'renders a download icon' do
      expect(helper.file_type_icon('image/vnd.dwg')).to include('<i')
      expect(helper.file_type_icon('image/vnd.dwg')).to include('file-download')
    end
  end

  describe '.spinner_icon' do
    it 'renders a spinner icon' do
      expect(helper.spinner_icon).to include('<i')
      expect(helper.spinner_icon).to include('fa-spinner fa-spin')
    end
  end

  describe 'nice_date_times' do
    let(:utc_date_time) { Time.zone.now }
    let(:utc_nice_date_time) { nice_date_times(utc_date_time) }

    context "localtime option is true" do
      subject { nice_date_times(utc_date_time, localtime: true) }

      context "and display_timezone config option is not set" do
        before { Rails.application.config.display_timezone = nil }
        it { expect(subject).to eql(utc_nice_date_time) }
      end
      context "and display_timezone config option is set" do
        before { Rails.application.config.display_timezone = "Saskatchewan" }
        it { expect(subject).to_not eql(utc_nice_date_time) }
      end
    end

    context "localtime option is false" do
      subject { nice_date_times(utc_date_time, localtime: false) }

      context "and display_timezone config option is set" do
        before { Rails.application.config.display_timezone = "Saskatchewan" }
        it { expect(subject).to eql(utc_nice_date_time) }
      end
    end

    context "when date is nil" do
      subject {nice_date_times(nil)}
      it { expect(nice_date_times(nil)).to be_blank }
    end
  end

  describe '#current_locale' do
    it 'handles symbols' do
      expect(helper.current_locale?(:en)).to be_truthy
      expect(helper.current_locale?(:cy)).to be_falsey
    end
    it 'handles strings' do
      expect(helper.current_locale?('en')).to be_truthy
      expect(helper.current_locale?('cy')).to be_falsey
    end
  end

  describe 'nice_dates' do
    it 'outputs dates as strings' do
      # TODO: test for 1 through 31 and fix day names
      date = Date.strptime("01/01/2022", "%d/%m/%Y")
      I18n.locale = 'en'
      expect(helper.nice_dates(date)).to eq('Sat 1st Jan 2022')
      expect(helper.nice_dates(date)).to eq('Sat 1st Jan 2022')
      expect(helper.nice_dates(date)).to eq('Sat 1st Jan 2022')
      I18n.locale = 'cy'
      expect(helper.nice_dates(date)).to eq('Sad 1af Ion 2022')
      # Reset locale to English
      I18n.locale = :en
    end
  end

  describe '#path_with_locale' do
    it 'adds parameter when no other parameters' do
      expect(helper.path_with_locale('/search?q=blah', :cy)).to eq('/search?q=blah&locale=cy')
    end
    it 'adds parameter when other parameters' do
      expect(helper.path_with_locale('/search', :cy)).to eq('/search?locale=cy')
    end
  end
end
