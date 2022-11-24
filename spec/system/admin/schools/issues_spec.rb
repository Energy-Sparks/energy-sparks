require 'rails_helper'

RSpec.describe 'school issues', :issues, type: :system, include_application_helper: true do
  let!(:school_group_issues_admin) { create(:admin, name: "Group Issues Admin") }
  let!(:school_group) { create(:school_group, default_issues_admin_user: school_group_issues_admin )}
  let!(:school) { create(:school, school_group: school_group) }
  let!(:other_issues_admin) { create(:admin, name: "Other Issues Admin") }
  let!(:issue)   {}
  let!(:user)   {}

  shared_examples_for "a displayed issue" do
    it "displays issue" do
      expect(page).to have_content issue.issue_type.capitalize
      expect(page).to have_content issue.title
      expect(page).to have_content issue.description.to_plain_text
      expect(page).to have_content issue.fuel_type.capitalize
      expect(page).to have_content issue.status.capitalize if issue.issue_type == 'issue'
      expect(page).to have_content issue_admin.display_name
      expect(page).to have_content "Updated • #{user.display_name} • #{nice_date_times_today(issue.updated_at)}"
      expect(page).to have_content "Created • #{user.display_name} • #{nice_date_times_today(issue.created_at)}"
      expect(page).to have_css("i[class*='fa-thumbtack']") if issue.pinned?
    end
  end

  describe "Viewing school issues admin page" do
    before do
      sign_in(user) if user
      visit url_for([:admin, school, :issues])
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

      context "and creating a new issue" do
        Issue.issue_types.keys.each do |issue_type|
          it { expect(page).to have_link(text: /New #{issue_type.capitalize}/) }
          context "of type #{issue_type}" do
            before do
              click_link text: /New #{issue_type.capitalize}/
            end
            it { expect(page).to have_current_path(new_polymorphic_path([:admin, school, Issue], issue_type: issue_type)) }
            it { expect(page).to have_content("New #{issue_type.capitalize} for #{school.name}")}

            it "has default values" do
              expect(find_field('Title').text).to be_blank
              expect(find('trix-editor#issue_description')).to have_text('')
              expect(page).to have_select('Fuel type', selected: [])
              expect(page).to have_select('Status', selected: 'Open') if issue_type == 'issue'
              expect(page).to have_select('Assigned to', selected: school_group.default_issues_admin_user.display_name)
              expect(page).to have_unchecked_field('Pinned')
            end

            context "with required values missing" do
              before do
                click_button 'Save'
              end
              it "has error message on fields" do
                expect(page).to have_content "Title *\ncan't be blank"
                expect(page).to have_content "Description *\ncan't be blank"
              end
            end
            context "with fields filled in" do
              let(:frozen_time) { Time.now }
              before do
                Timecop.freeze(frozen_time)
                fill_in 'Title', with: "#{issue_type} title"
                fill_in_trix 'trix-editor#issue_description', with: "#{issue_type} desc"
                select 'Gas', from: 'Fuel type'
                select 'Other Issues Admin', from: 'Assigned to'
                check 'Pinned'
                click_button 'Save'
              end

              it "creates new issue" do
                expect(page).to have_content "#{issue_type.capitalize}"
                expect(page).to have_content "#{issue_type} title"
                expect(page).to have_content "#{issue_type} desc"
                expect(page).to have_content "Gas"
                expect(page).to have_content "Other Issues Admin"
                expect(page).to have_content "Updated • #{user.display_name} • #{nice_date_times_today(frozen_time)}"
                expect(page).to have_content "Created • #{user.display_name} • #{nice_date_times_today(frozen_time)}"
                expect(page).to have_css("i[class*='fa-thumbtack']")
              end
              after { Timecop.return }
            end
          end
        end
      end

      context "and editing an issue" do
        Issue.issue_types.keys.each do |issue_type|
          context "of type #{issue_type}" do
            let!(:issue) { create(:issue, issueable: school, issue_type: issue_type, fuel_type: :electricity, created_by: user, owned_by: school_group_issues_admin, pinned: true) }
            before do
              click_link("Edit")
            end
            it "shows edit form" do
              expect(page).to have_field('Title', with: issue.title)
              expect(find_field('issue[description]', type: :hidden).value).to eq(issue.description.to_plain_text)
              expect(page).to have_select('Fuel type', selected: issue.fuel_type.capitalize)
              expect(page).to have_select('Status', selected: issue.status.capitalize) if issue_type == 'issue'
              expect(page).to have_select('Issue type', selected: issue.issue_type.capitalize)
              expect(page).to have_select('Assigned to', selected: school_group_issues_admin.display_name)
              expect(page).to have_checked_field('Pinned')
            end
            context "and saving new values" do
              let(:frozen_time) { Time.now }
              let(:new_issue_type) { Issue.issue_types.keys.excluding(issue_type).first.capitalize }
              before do
                Timecop.freeze(frozen_time)
                fill_in 'Title', with: "#{issue_type} title"
                fill_in_trix 'trix-editor#issue_description', with: "#{issue_type} desc"
                select 'Gas', from: 'Fuel type'
                select 'Closed', from: 'Status' if issue_type == 'issue'
                select new_issue_type, from: 'Issue type'
                select 'Other Issues Admin', from: 'Assigned to'
                uncheck 'Pinned'
                click_button 'Save'
              end

              it "saves new values" do
                expect(page).to have_content new_issue_type
                expect(page).to have_content "#{issue_type} title"
                expect(page).to have_content "#{issue_type} desc"
                expect(page).to have_content "Gas"
                expect(page).to have_content "Closed" if new_issue_type == 'issue'
                expect(page).to have_content "Other Issues Admin"
                expect(page).to have_content "Updated • #{user.display_name} • #{nice_date_times_today(frozen_time)}"
                expect(page).to have_content "Created • #{user.display_name} • #{nice_date_times_today(issue.created_at)}"
                expect(page).to_not have_css("i[class*='fa-thumbtack']")
              end
              after { Timecop.return }
            end
          end
        end
      end

      context "and viewing index" do
        let(:issue) { create(:issue, issueable: school, issue_type: :issue, fuel_type: :gas, created_by: user, updated_by: user, owned_by: other_issues_admin) }

        it_behaves_like "a displayed issue" do
          let(:issue_admin) { other_issues_admin }
        end

        it { expect(page).to have_link('Delete') }
        context "and deleting a issue" do
          before do
            click_link("Delete")
          end
          it { expect(page).to have_current_path(polymorphic_path([:admin, school, Issue])) }
          it "does not show removed issue" do
            expect(page).to_not have_content issue.title
          end
        end

        it { expect(page).to have_link('View') }
        context "and clicking 'View'" do
          before do
            click_link("View")
          end
          it { expect(page).to have_current_path(polymorphic_path([:admin, school, issue])) }
          it_behaves_like "a displayed issue" do
            let(:issue_admin) { other_issues_admin }
          end
        end

        it { expect(page).to have_link('Resolve') }
        context "and clicking 'Resolve'" do
          before do
            click_link("Resolve")
          end
          it { expect(page).to have_current_path(polymorphic_path([:admin, school, Issue])) }
          it "displays issue as closed" do
            expect(page).to have_content "Closed"
          end
        end
      end
    end
  end
end
