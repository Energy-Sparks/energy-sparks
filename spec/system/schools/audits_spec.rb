require 'rails_helper'

describe 'Audits', :include_application_helper, type: :system do
  let!(:school) { create(:school) }
  let(:audit) do
    if Flipper.enabled?(:todos)
      create(:audit, :with_todos, title: 'Our audit', description: 'Description of the audit', school:)
    else
      create(:audit, :with_activity_and_intervention_types, title: 'Our audit', description: 'Description of the audit', school:)
    end
  end

  describe 'as an admin' do
    let(:admin) { create(:admin) }

    before do
      sign_in(admin)
      visit school_path(school)
    end

    it 'displays an link to manage audits' do
      within '#manage_school_menu' do
        click_on 'Manage Audits'
      end
      expect(page).to have_content('Energy audits')
      expect(page).to have_content('New audit')
    end

    context with_feature: :todos do
      it 'allows me to create, edit and delete an audit' do
        visit school_audits_path(school)
        click_on('New audit')
        fill_in 'Title', with: 'New audit'
        attach_file('audit[file]', Rails.root + 'spec/fixtures/images/newsletter-placeholder.png')
        click_on('Create')
        expect(page).to have_content('Audit created')
        expect(Observation.count).to be 1
        expect(Observation.first.points).to be 0
        expect(page).to have_content('New audit')
        click_on('Edit')
        fill_in_trix with: 'Summary of the audit'
        check 'Involved pupils'
        click_on('Update')
        expect(Observation.first.points).to eql Audits::AuditService::AUDIT_POINTS
        expect(page).to have_content('Summary of the audit')
        click_on('Remove')
        expect(page).to have_content('Audit was successfully deleted.')
        expect(Audit.count).to be 0
        expect(Observation.count).to be 0
      end

      context 'when adding activities and interventions', js: true do
        let!(:activity_type) { create(:activity_type) }
        let!(:intervention_type) { create(:intervention_type) }

        it 'saves activities and interventions' do
          visit school_audits_path(school)
          click_on('New audit')

          fill_in 'Title', with: 'New audit'
          attach_file('audit[file]', Rails.root + 'spec/fixtures/images/newsletter-placeholder.png')

          click_on 'Add activity'
          select_task(:activity_type, activity_type.name)

          click_on 'Add action'
          select_task(:intervention_type, intervention_type.name)

          click_on('Create')
          expect(page).to have_content('Audit created')

          audit = Audit.last
          expect(audit.title).to eq('New audit')
          expect(audit.intervention_type_tasks).to eq([intervention_type])
          expect(audit.activity_type_tasks).to eq([activity_type])
        end

        context 'when saving fails' do
          before do
            activity_type
            visit school_audits_path(school)
            click_on('New audit')
          end

          it 'shows title and file error messages' do
            click_on('Create')
            expect(page).to have_content("Title can't be blank")
            expect(page).to have_content("File can't be blank")
            within '.audit_title' do
              expect(page).to have_content("can't be blank")
            end
            within '#file_error' do
              expect(page).to have_content("can't be blank")
            end
          end

          it 'shows activity type error message' do
            click_on 'Add activity'
            click_on('Create')
            expect(page).to have_content('Activity must exist')
            within '#activity-type-todos' do
              expect(page).to have_content('must exist')
            end
          end

          it 'shows intervention type error message' do
            click_on 'Add action'
            click_on('Create')
            expect(page).to have_content('Action must exist')
            within '#intervention-type-todos' do
              expect(page).to have_content('must exist')
            end
          end

          it 'retains fields' do
            activity_type
            visit school_audits_path(school)
            click_on('New audit')

            click_on 'Add activity'
            select_task(:activity_type, activity_type.name)

            click_on 'Add action'
            select_task(:intervention_type, intervention_type.name)

            click_on('Create')
            expect(page).to have_content("can't be blank")

            fill_in 'Title', with: 'New audit'
            attach_file('audit[file]', Rails.root + 'spec/fixtures/images/newsletter-placeholder.png')

            click_on('Create')
            with_retry(Selenium::WebDriver::Error::UnknownError) { expect(page).to have_content('Audit created') }

            audit = Audit.last
            expect(audit.title).to eq('New audit')
            expect(audit.intervention_type_tasks).to eq([intervention_type])
            expect(audit.activity_type_tasks).to eq([activity_type])
          end
        end
      end
    end

    context without_feature: :todos do
      it 'allows me to create, edit and delete an audit' do
        visit school_audits_path(school)
        click_on('New audit')
        fill_in 'Title', with: 'New audit'
        attach_file('audit[file]', Rails.root + 'spec/fixtures/images/newsletter-placeholder.png')
        click_on('Create')
        expect(page).to have_content('Audit created')
        expect(Observation.count).to be 1
        expect(Observation.first.points).to be 0
        expect(page).to have_content('New audit')
        click_on('Edit')
        fill_in_trix with: 'Summary of the audit'
        check 'Involved pupils'
        click_on('Update')
        expect(Observation.first.points).to eql Audits::AuditService::AUDIT_POINTS
        expect(page).to have_content('Summary of the audit')
        click_on('Remove')
        expect(page).to have_content('Audit was successfully deleted.')
        expect(Audit.count).to be 0
        expect(Observation.count).to be 0
      end

      context 'when adding activities and interventions', js: true do
        let!(:activity_type) { create(:activity_type) }
        let!(:intervention_type) { create(:intervention_type) }

        it 'saves activities and interventions' do
          visit school_audits_path(school)
          click_on('New audit')

          fill_in 'Title', with: 'New audit'
          attach_file('audit[file]', Rails.root + 'spec/fixtures/images/newsletter-placeholder.png')

          click_on 'Add activity'
          within '#audit-activity-types' do
            expect(page).to have_css('.nested-fields')
            find(:xpath, "//option[contains(text(), '#{activity_type.name}')]").select_option
          end

          click_on 'Add action'
          within '#audit-intervention-types' do
            expect(page).to have_css('.nested-fields')
            find(:xpath, "//option[contains(text(), '#{intervention_type.name}')]").select_option
          end

          click_on('Create')
          with_retry(Selenium::WebDriver::Error::UnknownError) { expect(page).to have_content('Audit created') }

          audit = Audit.last
          expect(audit.title).to eq('New audit')
          expect(audit.intervention_types).to eq([intervention_type])
          expect(audit.activity_types).to eq([activity_type])
        end

        context 'when saving fails' do
          before do
            activity_type
            visit school_audits_path(school)
            click_on('New audit')
          end

          it 'shows title and file error messages' do
            click_on('Create')
            expect(page).to have_content("Title can't be blank")
            expect(page).to have_content("File can't be blank")
            within '.audit_title' do
              expect(page).to have_content("can't be blank")
            end
            within '#file_error' do
              expect(page).to have_content("can't be blank")
            end
          end

          it 'shows activity type error message' do
            click_on 'Add activity'
            click_on('Create')
            expect(page).to have_content('Audit activity types activity type must exist')
            expect(page).to have_content("Audit activity types activity type can't be blank")
            within '#audit-activity-types' do
              expect(page).to have_content("must exist and can't be blank")
            end
          end

          it 'shows intervention type error message' do
            click_on 'Add action'
            click_on('Create')
            expect(page).to have_content('Audit intervention types intervention type must exist')
            expect(page).to have_content("Audit intervention types intervention type can't be blank")
            within '#audit-intervention-types' do
              expect(page).to have_content("must exist and can't be blank")
            end
          end

          it 'retains fields' do
            activity_type
            visit school_audits_path(school)
            click_on('New audit')

            click_on 'Add activity'
            within '#audit-activity-types' do
              find(:xpath, "//option[contains(text(), '#{activity_type.name}')]").select_option
            end

            click_on 'Add action'
            within '#audit-intervention-types' do
              find(:xpath, "//option[contains(text(), '#{intervention_type.name}')]").select_option
            end

            click_on('Create')
            expect(page).to have_content("can't be blank")

            fill_in 'Title', with: 'New audit'
            attach_file('audit[file]', Rails.root + 'spec/fixtures/images/newsletter-placeholder.png')

            click_on('Create')
            with_retry(Selenium::WebDriver::Error::UnknownError) { expect(page).to have_content('Audit created') }

            audit = Audit.last
            expect(audit.title).to eq('New audit')
            expect(audit.intervention_types).to eq([intervention_type])
            expect(audit.activity_types).to eq([activity_type])
          end
        end
      end
    end
  end

  describe 'as a school admin' do
    let!(:school_admin) { create(:school_admin, school: school) }

    before do
      sign_in(school_admin)
      visit school_path(school)
    end

    it 'doesnt have link to manage audits' do
      expect(page).not_to have_content('Manage Audits')
    end

    context 'with no audit' do
      before do
        visit school_audits_path(school)
      end

      it 'shows introductory page' do
        expect(page).to have_content('Energy audits: turn data into action')
      end
    end

    context 'with an audit', without_feature: :todos do
      let!(:audit) { create(:audit, :with_activity_and_intervention_types, title: 'Our audit', description: 'Description of the audit', school: school) }

      let!(:other_audit) { create(:audit, :with_activity_and_intervention_types, title: 'Unpublished', description: 'Description of the audit', school: school, published: false) }

      before do
        Audits::AuditService.new(school).process(audit)
        Audits::AuditService.new(school).process(other_audit)
      end

      it 'lets me view a list of audits' do
        visit school_audits_path(school)
        expect(page).not_to have_content('The Energy Sparks team have not carried out an energy audit for your school')
        expect(page).to have_content('Our audit')
        expect(page).to have_content(audit.created_at.strftime('%A, %d %B %Y'))
      end

      it 'doesnt show unpublished audits' do
        visit school_audits_path(school)
        expect(page).not_to have_content('Unpublished')
      end

      it 'gives link to book another audit' do
        visit school_audits_path(school)
        click_link 'Book another audit'
        expect(page).to have_content('Energy audits: turn data into action')
      end

      it 'doesnt show admin options on list of audits' do
        visit school_audits_path(school)
        expect(page).not_to have_content('New audit')
        within '#audits' do
          expect(page).not_to have_content('Edit')
          expect(page).not_to have_content('Remove')
        end
      end

      it 'lets me view an audit' do
        visit school_audits_path(school)
        click_on('Our audit')
        expect(page).to have_content('Our audit')
        expect(page).to have_content('Description of the audit')
        expect(page).to have_link('View all audits')
        expect(page).to have_link(href: rails_blob_path(audit.file))
      end

      it 'doesnt show admin options when viewing audit' do
        visit school_audits_path(school)
        click_on('Our audit')
        expect(page).not_to have_css('#audit-admin-tools')
      end

      it 'shows links to all activities' do
        visit school_audits_path(school)
        click_on('Our audit')
        audit.audit_activity_types.each do |at|
          expect(page).to have_link(at.activity_name, href: activity_type_path(at.activity_type))
        end
      end

      it 'shows links to all actions' do
        visit school_audits_path(school)
        click_on('Our audit')
        audit.audit_intervention_types.each do |at|
          expect(page).to have_link(at.intervention_name, href: intervention_type_path(at.intervention_type))
        end
      end

      it 'shows audit in timeline' do
        visit school_path(school)
        expect(page).to have_content('Received an energy audit')
      end
    end

    context 'with an audit', with_feature: :todos do
      let!(:other_audit) { create(:audit, :with_todos, title: 'Unpublished', description: 'Description of the audit', school:, published: false) }

      before do
        Audits::AuditService.new(school).process(audit)
        Audits::AuditService.new(school).process(other_audit)
        visit school_audits_path(school)
      end

      it 'lets me view a list of audits' do
        expect(page).not_to have_content('The Energy Sparks team have not carried out an energy audit for your school')
        expect(page).to have_content('Our audit')
        expect(page).to have_content(audit.created_at.strftime('%A, %d %B %Y'))
      end

      it 'doesnt show unpublished audits' do
        expect(page).not_to have_content('Unpublished')
      end

      it 'gives link to book another audit' do
        click_link 'Book another audit'
        expect(page).to have_content('Energy audits: turn data into action')
      end

      it 'doesnt show admin options on list of audits' do
        expect(page).not_to have_content('New audit')
        within '#audits' do
          expect(page).not_to have_content('Edit')
          expect(page).not_to have_content('Remove')
        end
      end

      context 'when viewing an audit' do
        before do
          click_on('Our audit')
        end

        it 'lets me view an audit' do
          expect(page).to have_content('Our audit')
          expect(page).to have_content('Description of the audit')
          expect(page).to have_link('View all audits')
          expect(page).to have_link(href: rails_blob_path(audit.file))
        end

        it 'doesnt show admin options when viewing audit' do
          expect(page).not_to have_css('#audit-admin-tools')
        end

        it_behaves_like 'a todo list when there is a completable' do
          let(:assignable) { audit }
        end
      end

      it 'shows audit in timeline' do
        visit school_path(school)
        expect(page).to have_content('Received an energy audit')
      end
    end
  end

  context toggle_feature: :todos do
    describe 'as a staff member' do
      let!(:staff) { create(:staff, school: school) }

      before do
        Audits::AuditService.new(school).process(audit)
        sign_in(staff)
        visit school_path(school)
      end

      it 'shows audit in timeline' do
        expect(page).to have_content('Received an energy audit')
      end

      context 'when viewing an audit', if: Flipper.enabled?(:todos) do
        before do
          visit school_audit_path(school, audit)
        end

        it_behaves_like 'a todo list when there is a completable' do
          let(:assignable) { audit }
        end
      end
    end

    describe 'as pupil' do
      let(:pupil) { create(:pupil, school: school)}

      before do
        Audits::AuditService.new(school).process(audit)
        sign_in(pupil)
        visit school_path(school)
      end

      it 'shows audit in timeline' do
        expect(page).to have_content('Received an energy audit')
      end

      context 'when viewing an audit', if: Flipper.enabled?(:todos) do
        before do
          visit school_audit_path(school, audit)
        end

        it_behaves_like 'a todo list when there is a completable' do
          let(:assignable) { audit }
        end
      end
    end

    describe 'as a guest user' do
      before do
        Audits::AuditService.new(school).process(audit)
      end

      it 'shows audit in timeline' do
        visit school_path(school)
        expect(page).to have_content('Received an energy audit')
      end

      it 'does not let me view list of audits' do
        visit school_audits_path(school)
        expect(page).to have_content('You need to sign in')
      end

      it 'does not let me view an audit' do
        visit school_audit_path(school, audit)
        expect(page).to have_content('You need to sign in')
      end
    end
  end
end
