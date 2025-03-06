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
      expect(helper.up_downify('hello')).not_to include('<i')
      expect(helper.up_downify('hello + goodbye')).not_to include('<i')
    end

    context 'with sanitize set to true (default)' do
      it { expect(helper.up_downify('10.1&percnt;')).to eq('10.1&amp;percnt; ') } # we don't want this!
      it { expect(helper.up_downify('10.1%')).to eq('10.1% ') }
    end

    context 'with sanitize set to false' do
      it { expect(helper.up_downify('10.1&percnt;', sanitize: false)).to eq('10.1&percnt; ') }
      it { expect(helper.up_downify('10.1%', sanitize: false)).to eq('10.1% ') }
    end
  end

  describe 'last signed in helper' do
    it 'shows a message if a user has never signed in' do
      expect(display_last_signed_in_as(build(:user))).to eq '-'
    end

    it 'shows the last time as user signed in' do
      last_sign_in_at = DateTime.new(2001, 2, 3, 4, 5, 6)
      expect(display_last_signed_in_as(build(:user, last_sign_in_at: last_sign_in_at))).to eq last_sign_in_at.strftime('%d/%m/%Y %H:%M')
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
      expect(helper.human_counts([1, 2])).to eq('twice')
    end

    it 'shows more than 2 as several times' do
      expect(helper.human_counts([1, 2, 3])).to eq('several times')
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

    context 'localtime option is true' do
      subject { nice_date_times(utc_date_time, localtime: true) }

      context 'and display_timezone config option is not set' do
        before { Rails.application.config.display_timezone = nil }

        it { expect(subject).to eql(utc_nice_date_time) }
      end

      context 'and display_timezone config option is set' do
        before { Rails.application.config.display_timezone = 'Saskatchewan' }

        it { expect(subject).not_to eql(utc_nice_date_time) }
      end
    end

    context 'localtime option is false' do
      subject { nice_date_times(utc_date_time, localtime: false) }

      context 'and display_timezone config option is set' do
        before { Rails.application.config.display_timezone = 'Saskatchewan' }

        it { expect(subject).to eql(utc_nice_date_time) }
      end
    end

    context 'when date is nil' do
      subject {nice_date_times(nil)}

      it { expect(nice_date_times(nil)).to be_blank }
    end
  end

  describe '#current_locale' do
    it 'handles symbols' do
      expect(helper).to be_current_locale(:en)
      expect(helper).not_to be_current_locale(:cy)
    end

    it 'handles strings' do
      expect(helper).to be_current_locale('en')
      expect(helper).not_to be_current_locale('cy')
    end
  end

  describe 'nice_dates' do
    before { I18n.locale = 'en' }
    after { I18n.locale = 'en' }

    it 'outputs dates as strings in a nice way' do
      # Test for no date
      expect(helper.nice_dates(nil)).to eq('')
      # Test for changes in abbreviated day output
      expect(helper.nice_dates(Date.strptime('01/01/2022', '%d/%m/%Y'))).to eq('Sat 1st Jan 2022')
      expect(helper.nice_dates(Date.strptime('02/01/2022', '%d/%m/%Y'))).to eq('Sun 2nd Jan 2022')
      expect(helper.nice_dates(Date.strptime('03/01/2022', '%d/%m/%Y'))).to eq('Mon 3rd Jan 2022')
      expect(helper.nice_dates(Date.strptime('04/01/2022', '%d/%m/%Y'))).to eq('Tue 4th Jan 2022')
      expect(helper.nice_dates(Date.strptime('05/01/2022', '%d/%m/%Y'))).to eq('Wed 5th Jan 2022')
      expect(helper.nice_dates(Date.strptime('06/01/2022', '%d/%m/%Y'))).to eq('Thu 6th Jan 2022')
      expect(helper.nice_dates(Date.strptime('07/01/2022', '%d/%m/%Y'))).to eq('Fri 7th Jan 2022')
      expect(helper.nice_dates(Date.strptime('08/01/2022', '%d/%m/%Y'))).to eq('Sat 8th Jan 2022')
      expect(helper.nice_dates(Date.strptime('09/01/2022', '%d/%m/%Y'))).to eq('Sun 9th Jan 2022')
      expect(helper.nice_dates(Date.strptime('10/01/2022', '%d/%m/%Y'))).to eq('Mon 10th Jan 2022')
      expect(helper.nice_dates(Date.strptime('11/01/2022', '%d/%m/%Y'))).to eq('Tue 11th Jan 2022')
      expect(helper.nice_dates(Date.strptime('12/01/2022', '%d/%m/%Y'))).to eq('Wed 12th Jan 2022')
      expect(helper.nice_dates(Date.strptime('13/01/2022', '%d/%m/%Y'))).to eq('Thu 13th Jan 2022')
      expect(helper.nice_dates(Date.strptime('14/01/2022', '%d/%m/%Y'))).to eq('Fri 14th Jan 2022')
      expect(helper.nice_dates(Date.strptime('15/01/2022', '%d/%m/%Y'))).to eq('Sat 15th Jan 2022')
      expect(helper.nice_dates(Date.strptime('16/01/2022', '%d/%m/%Y'))).to eq('Sun 16th Jan 2022')
      expect(helper.nice_dates(Date.strptime('17/01/2022', '%d/%m/%Y'))).to eq('Mon 17th Jan 2022')
      expect(helper.nice_dates(Date.strptime('18/01/2022', '%d/%m/%Y'))).to eq('Tue 18th Jan 2022')
      expect(helper.nice_dates(Date.strptime('19/01/2022', '%d/%m/%Y'))).to eq('Wed 19th Jan 2022')
      expect(helper.nice_dates(Date.strptime('20/01/2022', '%d/%m/%Y'))).to eq('Thu 20th Jan 2022')
      expect(helper.nice_dates(Date.strptime('21/01/2022', '%d/%m/%Y'))).to eq('Fri 21st Jan 2022')
      expect(helper.nice_dates(Date.strptime('22/01/2022', '%d/%m/%Y'))).to eq('Sat 22nd Jan 2022')
      expect(helper.nice_dates(Date.strptime('23/01/2022', '%d/%m/%Y'))).to eq('Sun 23rd Jan 2022')
      expect(helper.nice_dates(Date.strptime('24/01/2022', '%d/%m/%Y'))).to eq('Mon 24th Jan 2022')
      expect(helper.nice_dates(Date.strptime('25/01/2022', '%d/%m/%Y'))).to eq('Tue 25th Jan 2022')
      expect(helper.nice_dates(Date.strptime('26/01/2022', '%d/%m/%Y'))).to eq('Wed 26th Jan 2022')
      expect(helper.nice_dates(Date.strptime('27/01/2022', '%d/%m/%Y'))).to eq('Thu 27th Jan 2022')
      expect(helper.nice_dates(Date.strptime('28/01/2022', '%d/%m/%Y'))).to eq('Fri 28th Jan 2022')
      expect(helper.nice_dates(Date.strptime('29/01/2022', '%d/%m/%Y'))).to eq('Sat 29th Jan 2022')
      expect(helper.nice_dates(Date.strptime('30/01/2022', '%d/%m/%Y'))).to eq('Sun 30th Jan 2022')
      expect(helper.nice_dates(Date.strptime('31/01/2022', '%d/%m/%Y'))).to eq('Mon 31st Jan 2022')
      # Test for changes in abbreviated month output
      expect(helper.nice_dates(Date.strptime('01/02/2022', '%d/%m/%Y'))).to eq('Tue 1st Feb 2022')
      expect(helper.nice_dates(Date.strptime('01/03/2022', '%d/%m/%Y'))).to eq('Tue 1st Mar 2022')
      expect(helper.nice_dates(Date.strptime('01/04/2022', '%d/%m/%Y'))).to eq('Fri 1st Apr 2022')
      expect(helper.nice_dates(Date.strptime('01/05/2022', '%d/%m/%Y'))).to eq('Sun 1st May 2022')
      expect(helper.nice_dates(Date.strptime('01/06/2022', '%d/%m/%Y'))).to eq('Wed 1st Jun 2022')
      expect(helper.nice_dates(Date.strptime('01/07/2022', '%d/%m/%Y'))).to eq('Fri 1st Jul 2022')
      expect(helper.nice_dates(Date.strptime('01/08/2022', '%d/%m/%Y'))).to eq('Mon 1st Aug 2022')
      expect(helper.nice_dates(Date.strptime('01/09/2022', '%d/%m/%Y'))).to eq('Thu 1st Sep 2022')
      expect(helper.nice_dates(Date.strptime('01/10/2022', '%d/%m/%Y'))).to eq('Sat 1st Oct 2022')
      expect(helper.nice_dates(Date.strptime('01/11/2022', '%d/%m/%Y'))).to eq('Tue 1st Nov 2022')
      expect(helper.nice_dates(Date.strptime('01/12/2022', '%d/%m/%Y'))).to eq('Thu 1st Dec 2022')
    end
  end

  describe 'nice_times_only' do
    before { I18n.locale = 'en' }
    after { I18n.locale = 'en' }

    it 'outputs times as strings in a nice way' do
      start_of_the_day = DateTime.new(2022, 1, 1, 0, 0, 0).to_i
      end_of_the_day = DateTime.new(2022, 1, 1, 23, 30, 0).to_i
      times = (start_of_the_day..end_of_the_day).step(30.minutes)
      times = times.map { |time| helper.nice_times_only(Time.zone.at(time)) }
      expect(times).to eq(
        ['00:00', '00:30', '01:00', '01:30', '02:00', '02:30', '03:00', '03:30', '04:00', '04:30', '05:00', '05:30', '06:00', '06:30', '07:00', '07:30', '08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00', '17:30', '18:00', '18:30', '19:00', '19:30', '20:00', '20:30', '21:00', '21:30', '22:00', '22:30', '23:00', '23:30']
      )
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

  describe '#i18n_key_from' do
    it 'handles simple strings' do
      expect(helper.i18n_key_from('Electricity+Solar PV')).to eq('electricity_and_solar_pv')
    end

    it 'handles simple strings' do
      expect(helper.i18n_key_from('Gas')).to eq('gas')
    end

    it 'removes spaces' do
      expect(helper.i18n_key_from('some thing')).to eq('something')
    end

    it 'adds underscores between caps' do
      expect(helper.i18n_key_from('SomeThing')).to eq('some_thing')
    end

    it 'applies both' do
      expect(helper.i18n_key_from('Some Thing')).to eq('some_thing')
    end
  end

  describe '#school_name_group' do
    let(:school_with_group) do
      school = ActiveSupport::OrderedOptions.new
      school.name = 'School One'
      school.school_group_name = 'Some School Group'
      school
    end
    let(:school_without_group) do
      school = ActiveSupport::OrderedOptions.new
      school.name = 'School Two'
      school
    end

    it 'handles school with group' do
      expect(helper.school_name_group(school_with_group)).to eq('School One (Some School Group)')
    end

    it 'handles school without group' do
      expect(helper.school_name_group(school_without_group)).to eq('School Two')
    end
  end

  describe '#status_for_alert_colour' do
    it 'returns neutral if no colour supplied' do
      expect(helper.status_for_alert_colour(nil)).to eq(:neutral)
    end

    it 'returns colour if supplied' do
      expect(helper.status_for_alert_colour(:green)).to eq(:green)
    end
  end

  describe '#user_school_role' do
    let(:user_with_staff_role) { create(:staff) }
    let(:user_without_staff_role) { create(:group_admin) }

    it 'returns staff role title' do
      expect(helper.user_school_role(user_with_staff_role)).to eq('Teacher')
    end

    it 'returns role' do
      expect(helper.user_school_role(user_without_staff_role)).to eq('Group admin')
    end
  end
end
