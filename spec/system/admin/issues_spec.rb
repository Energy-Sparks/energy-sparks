require 'rails_helper'

RSpec.describe 'issues', :issues, type: :system, include_application_helper: true do
  let!(:school_group_issues_admin) { create(:admin, name: 'Group Issues Admin') }
  let!(:school_group) { create(:school_group, default_issues_admin_user: school_group_issues_admin)}
  let!(:school) { create(:school, school_group: school_group) }
  let!(:gas_meter) { create(:gas_meter, name: nil, school: school) }
  let!(:electricity_meter) { create(:electricity_meter, school: school) }
  let!(:other_issues_admin) { create(:admin, name: 'Other Issues Admin') }
  let!(:issue) {}
  let!(:user) {}

  shared_examples 'an adminable issueable type' do
    describe 'Viewing issues admin page' do
      before do
        sign_in(user) if user
        visit url_for([:admin, issueable, :issues])
      end

      context 'when not logged in' do
        let!(:user) { }

        it { expect(page).to have_content('You need to sign in or sign up before continuing.') }
      end

      context 'as a non-admin user' do
        let!(:user) { create(:staff) }

        it { expect(page).to have_content('You are not authorized to view that page.') }
      end

      context 'as an admin' do
        let!(:user) { create(:admin) }

        context 'and creating a new issue' do
          Issue.issue_types.each_key do |issue_type|
            it { expect(page).to have_link(text: /New #{issue_type.capitalize}/) }

            context "of type #{issue_type}" do
              before do
                click_link text: /New #{issue_type.capitalize}/
              end

              it { expect(page).to have_current_path(new_polymorphic_path([:admin, issueable, Issue], issue_type: issue_type)) }
              it { expect(page).to have_content("New #{issue_type.capitalize} for #{issueable.name}")}

              it 'has default values' do
                expect(find_field('Title').text).to be_blank
                expect(find('trix-editor#issue_description')).to have_text('')
                expect(page).to have_select('Fuel type', selected: [])
                expect(page).to have_select('Status', selected: 'Open') if issue_type == 'issue'
                assigned_to = issueable.is_a?(DataSource) ? [] : issueable.default_issues_admin_user.display_name
                expect(page).to have_select('Assigned to', selected: assigned_to)
                expect(find_field('Review date').value).to be_blank
                expect(page).to have_unchecked_field('Pinned')
                if issueable.is_a? School
                  expect(page).to have_unchecked_field(electricity_meter.mpan_mprn.to_s)
                  expect(page).to have_unchecked_field(gas_meter.mpan_mprn.to_s)
                end
              end

              context 'with required values missing' do
                before do
                  click_button 'Save'
                end

                it 'has error message on fields' do
                  expect(page).to have_content "Title *\ncan't be blank"
                  expect(page).to have_content "Description *\ncan't be blank"
                end

                context 'and then saving with correct values' do
                  before do
                    fill_in 'Title', with: "#{issue_type} title"
                    fill_in_trix 'trix-editor#issue_description', with: "#{issue_type} desc"
                    click_button 'Save'
                  end

                  it 'redirects back to the calling page' do
                    expect(page).to have_current_path(url_for([:admin, issueable, :issues]))
                  end
                end
              end

              context 'with fields filled in' do
                let(:frozen_time) { Time.zone.now }

                before do
                  travel_to(frozen_time)
                  fill_in 'Title', with: "#{issue_type} title"
                  fill_in_trix 'trix-editor#issue_description', with: "#{issue_type} desc"
                  select 'Gas', from: 'Fuel type'
                  check gas_meter.mpan_mprn.to_s if issueable.is_a? School
                  select 'Other Issues Admin', from: 'Assigned to'
                  fill_in 'Review date', with: (frozen_time + 7.days).strftime('%d/%m/%Y')
                  check 'Pinned'
                  click_button 'Save'
                end

                it 'creates new issue' do
                  expect(page).to have_content issue_type.capitalize.to_s
                  expect(page).to have_content "#{issue_type} title"
                  expect(page).to have_content "#{issue_type} desc"
                  expect(page).to have_content 'Gas'
                  expect(page).to have_content 'Other Issues Admin'
                  expect(page).to have_content "Updated • #{user.display_name} • #{nice_date_times_today(frozen_time)}"
                  expect(page).to have_content "Created • #{user.display_name} • #{nice_date_times_today(frozen_time)}"
                  expect(page).to have_content "Review • #{nice_date_times_today(frozen_time + 7.days)}"
                  expect(page).to have_css("i[class*='fa-thumbtack']")
                  if issueable.is_a? School
                    expect(page).not_to have_content electricity_meter.mpan_mprn
                    expect(page).to have_content gas_meter.mpan_mprn
                  end
                end
              end
            end
          end
        end

        context 'and editing an issue' do
          Issue.issue_types.each_key do |issue_type|
            context "of type #{issue_type}" do
              let(:date) { Time.zone.today }

              let!(:issue) do
                create(:issue, issueable: issueable, issue_type: issue_type,
                fuel_type: :electricity, created_by: user, owned_by: school_group_issues_admin, review_date: date, pinned: true)
              end

              before do
                issue.meters << electricity_meter if issueable.is_a? School
                click_link('Edit')
              end

              it 'shows edit form' do
                expect(page).to have_field('Title', with: issue.title)
                expect(find_field('issue[description]', type: :hidden).value).to eq(issue.description.to_plain_text)
                expect(page).to have_select('Fuel type', selected: issue.fuel_type.capitalize)
                expect(page).to have_select('Status', selected: issue.status.capitalize) if issue_type == 'issue'
                expect(page).to have_select('Issue type', selected: issue.issue_type.capitalize)
                expect(page).to have_select('Assigned to', selected: school_group_issues_admin.display_name)
                expect(page).to have_field('Review date', with: date.strftime('%d/%m/%Y'))
                expect(page).to have_checked_field('Pinned')
                if issueable.is_a? School
                  expect(page).to have_checked_field(electricity_meter.mpan_mprn.to_s)
                  expect(page).to have_unchecked_field(gas_meter.mpan_mprn.to_s)
                end
              end

              context 'and saving new values' do
                let(:frozen_time) { Time.zone.now }
                let(:new_issue_type) { Issue.issue_types.keys.excluding(issue_type).first.capitalize }

                before do
                  travel_to(frozen_time)
                  fill_in 'Title', with: "#{issue_type} title"
                  fill_in_trix 'trix-editor#issue_description', with: "#{issue_type} desc"
                  select 'Gas', from: 'Fuel type'
                  select 'Closed', from: 'Status' if issue_type == 'issue'
                  select new_issue_type, from: 'Issue type'
                  select 'Other Issues Admin', from: 'Assigned to'
                  fill_in 'Review date', with: (frozen_time + 7.days).strftime('%d/%m/%Y')
                  uncheck 'Pinned'
                  if issueable.is_a? School
                    uncheck electricity_meter.mpan_mprn.to_s
                    check gas_meter.mpan_mprn.to_s
                  end
                  click_button 'Save'
                end

                it 'saves new values' do
                  expect(page).to have_content new_issue_type
                  expect(page).to have_content "#{issue_type} title"
                  expect(page).to have_content "#{issue_type} desc"
                  expect(page).to have_content 'Gas'
                  expect(page).to have_content 'Closed' if new_issue_type == 'issue'
                  expect(page).to have_content 'Other Issues Admin'
                  expect(page).to have_content "Updated • #{user.display_name} • #{nice_date_times_today(frozen_time)}"
                  expect(page).to have_content "Created • #{user.display_name} • #{nice_date_times_today(issue.created_at)}"
                  expect(page).to have_content "Review • #{nice_date_times_today(frozen_time + 7.days)}"
                  expect(page).not_to have_css("i[class*='fa-thumbtack']")
                  if issueable.is_a? School
                    expect(page).to have_content gas_meter.mpan_mprn
                    expect(page).not_to have_content electricity_meter.mpan_mprn
                  end
                end
              end
            end
          end
        end

        context 'and viewing index' do
          let(:issue) { create(:issue, issueable: issueable, issue_type: :issue, fuel_type: :gas, created_by: user, updated_by: user, owned_by: other_issues_admin) }

          it_behaves_like 'a displayed issue' do
            let(:issue_admin) { other_issues_admin }
          end

          it { expect(page).to have_link('Delete') }

          context 'displaying school context menu' do
            it { expect(page).to have_link('Manage School') if issueable.is_a?(School) }
            it { expect(page).not_to have_link('Manage School') unless issueable.is_a?(School) }
          end

          context 'and deleting a issue' do
            before do
              click_link('Delete')
            end

            it { expect(page).to have_current_path(polymorphic_path([:admin, issueable, Issue])) }

            it 'does not show removed issue' do
              expect(page).not_to have_content issue.title
            end
          end

          it { expect(page).to have_link('View') }

          context "and clicking 'View'" do
            before do
              click_link('View')
            end

            it { expect(page).to have_current_path(polymorphic_path([:admin, issueable, issue])) }

            it_behaves_like 'a displayed issue' do
              let(:issue_admin) { other_issues_admin }
            end
          end

          it { expect(page).to have_link('Resolve') }

          context "and clicking 'Resolve'" do
            before do
              click_link('Resolve')
            end

            it { expect(page).to have_current_path(polymorphic_path([:admin, issueable, Issue])) }

            it 'displays issue as closed' do
              expect(page).to have_content 'Closed'
            end
          end
        end
      end
    end
  end

  describe 'for issueable' do
    context 'school' do
      it_behaves_like 'an adminable issueable type' do
        let(:issueable) { school }
      end
    end

    context 'school group' do
      it_behaves_like 'an adminable issueable type' do
        let(:issueable) { school_group }
      end
    end

    context 'data source' do
      let(:data_source) { create(:data_source) }

      it_behaves_like 'an adminable issueable type' do
        let(:issueable) { data_source }
      end
    end
  end

  context 'as an admin' do
    let!(:user) { create(:admin) }
    let!(:setup_data) {}

    before do
      sign_in(user)
    end

    describe 'index' do
      before do
        setup_data
        visit admin_issues_url
      end

      it { expect(page).to have_select(:user, selected: []) }
      it { expect(page).to have_checked_field('Issue') }
      it { expect(page).to have_checked_field('Note') }
      it { expect(page).to have_checked_field('Open') }
      it { expect(page).to have_checked_field('Closed') }

      context 'showing defaults' do
        let(:open_issue) { create :issue, status: :open }
        let(:closed_issue) { create :issue, status: :closed }
        let(:issue_issue) { create :issue }
        let(:note_issue) { create :issue, issue_type: :note, pinned: true}
        let(:setup_data) { [open_issue, closed_issue, issue_issue, note_issue]}

        it_behaves_like 'a displayed list issue' do
          let(:issue) { open_issue }
        end
        it_behaves_like 'a displayed list issue' do
          let(:issue) { closed_issue }
        end
        it_behaves_like 'a displayed list issue' do
          let(:issue) { issue_issue }
        end
        it_behaves_like 'a displayed list issue' do
          let(:issue) { note_issue }
        end

        context 'and deselecting notes' do
          before do
            uncheck 'Note'
            click_button 'Filter'
          end

          it 'only shows issues' do
            expect(page).not_to have_content note_issue.title
            expect(page).to have_content issue_issue.title
          end
        end

        context 'and deselecting issues' do
          before do
            uncheck 'Issue'
            click_button 'Filter'
          end

          it 'only shows notes' do
            expect(page).to have_content note_issue.title
            expect(page).not_to have_content issue_issue.title
          end
        end

        context 'and deselecting open' do
          before do
            uncheck 'Open'
            click_button 'Filter'
          end

          it 'onlies show closed issues' do
            expect(page).not_to have_content open_issue.title
            expect(page).to have_content closed_issue.title
          end
        end

        context 'and deselecting closed' do
          before do
            uncheck 'Closed'
            click_button 'Filter'
          end

          it 'onlies show open issues' do
            expect(page).to have_content open_issue.title
            expect(page).not_to have_content closed_issue.title
          end
        end
      end

      context 'and selecting a user' do
        let!(:user_issue) { create(:issue, owned_by: user)}
        let!(:other_user_issue) { create(:issue, owned_by: create(:admin, name: 'Not you'))}
        let(:setup_data) { [user_issue, other_user_issue] }

        before do
          select user.display_name, from: :user
          click_button 'Filter'
        end

        it_behaves_like 'a displayed list issue' do
          let(:issue) { user_issue }
        end

        it "doesn't display issue for other user" do
          expect(page).not_to have_content other_user_issue.title
        end
      end

      context 'and filtering by review date' do
        let!(:issue_overdue) { create(:issue, review_date: 2.days.ago) }
        let!(:issue_next_week) { create(:issue, review_date: 5.days.from_now) }
        let!(:issue_week_after_next) { create(:issue, review_date: 10.days.from_now) }
        let!(:issue_no_review_date) { create(:issue, review_date: nil) }
        let(:issues) { [issue_overdue, issue_next_week, issue_week_after_next, issue_no_review_date]}
        let(:setup_data) { issues }

        context 'when selecting any review date' do
          before do
            select 'Any review date', from: :review_date
            click_button 'Filter'
          end

          it 'shows all issues' do
            issues.each do |issue|
              expect(page).to have_content issue.title
            end
          end
        end

        context 'when selecting review date not set' do
          before do
            select 'Review date not set', from: :review_date
            click_button 'Filter'
          end

          it_behaves_like 'a displayed list issue' do
            let(:issue) { issue_no_review_date }
            let(:all_issues) { issues }
          end
        end

        context 'when selecting review date in next week' do
          before do
            select 'Review date in next week', from: :review_date
            click_button 'Filter'
          end

          it_behaves_like 'a displayed list issue' do
            let(:issue) { issue_next_week }
            let(:all_issues) { issues }
          end
        end

        context 'when selecting review date overdue' do
          before do
            select 'Review date overdue', from: :review_date
            click_button 'Filter'
          end

          it_behaves_like 'a displayed list issue' do
            let(:issue) { issue_overdue }
            let(:all_issues) { issues }
          end
        end
      end

      context 'and searching issues' do
        let(:issue_1) { create(:issue, title: 'Issue 1 findme here', description: 'description') }
        let(:issue_2) { create(:issue, title: 'Issue 2 title', description: 'I\'m hiding here') }
        let(:setup_data) { [issue_1, issue_2] }

        before do
          fill_in :search, with: 'findme|hiding'
          click_button 'Filter'
        end

        it_behaves_like 'a displayed list issue' do
          let(:issue) { issue_1 }
        end
        it_behaves_like 'a displayed list issue' do
          let(:issue) { issue_2 }
        end
      end

      context 'when there are no issues' do
        let(:setup_data) {}

        it { expect(page).to have_content('No issues or notes to display')}
      end
    end
  end
end
