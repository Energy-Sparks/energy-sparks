require 'rails_helper'

describe 'Audits', type: :system do

  let!(:school)            { create(:school) }

  describe 'as an admin' do
    let(:admin) { create(:admin) }

    before(:each) do
      sign_in(admin)
      visit school_path(school)
    end

    it 'displays an link to manage audits' do
      within '#manage_school_menu' do
        click_on 'Manage Audits'
      end
      expect(page).to have_content("Energy audits")
      expect(page).to have_content("New audit")
    end

    it 'allows me to create, edit and delete an audit' do
      visit school_audits_path(school)
      click_on("New audit")
      fill_in "Title", with: "New audit"
      click_on("Create")
      expect(page).to have_content("can't be blank")
      attach_file("audit[file]", Rails.root + "spec/fixtures/images/newsletter-placeholder.png")
      click_on("Create")
      expect(page).to have_content("New audit")
      click_on("Edit")
      fill_in_trix with: 'Summary of the audit'
      click_on("Update")
      expect(page).to have_content("Summary of the audit")
      click_on("Remove")
      expect(page).to have_content("Audit was successfully deleted.")
      expect(Audit.count).to eql 0
      expect(Observation.count).to eql 0
    end

    it 'allows me to add, edit and delete an activity'
    it 'allows me to add, edit and delete an action'
  end

  describe 'as a school admin' do
    let!(:school_admin)       { create(:school_admin, school: school) }

    before(:each) do
      sign_in(school_admin)
      visit school_path(school)
    end

    it 'doesnt have link to manage audits' do
      expect(page).to_not have_content("Manage Audits")
    end

    it 'displays a link to view audits' do
      within '#my_school_menu' do
        click_on 'Energy audits'
      end
      expect(page).to have_content("Energy audits")
    end

    context 'with no audit' do
      before(:each) do
        visit school_audits_path(school)
      end
      it 'says there are none' do
        expect(page).to have_content("The Energy Sparks team have not carried out an energy audit for your school")
      end
      it 'offers an audit' do
        expect(page).to have_content("We are currently offering audits to a limited number of schools")
      end
    end

    context 'with an audit' do
      let!(:audit) { create(:audit, :with_activity_and_intervention_types, title: "Our audit", description: "Description of the audit", school: school) }

      let!(:other_audit) { create(:audit, :with_activity_and_intervention_types, title: "Unpublished", description: "Description of the audit", school: school, published: false) }

      before(:each) do
        Audits::AuditService.new(school).process(audit)
        Audits::AuditService.new(school).process(other_audit)
      end

      it 'lets me view a list of audits' do
        visit school_audits_path(school)
        expect(page).to_not have_content("The Energy Sparks team have not carried out an energy audit for your school")
        expect(page).to have_content("Our audit")
        expect(page).to have_content(audit.created_at.strftime("%A, %d %B %Y"))
      end

      it 'doesnt show unpublished audits' do
        visit school_audits_path(school)
        expect(page).to_not have_content("Unpublished")
      end

      it 'doesnt show admin options on list of audits' do
        visit school_audits_path(school)
        expect(page).to_not have_content("New audit")
        within '#audits' do
          expect(page).to_not have_content("Edit")
          expect(page).to_not have_content("Remove")
        end
      end

      it 'lets me view an audit' do
        visit school_audits_path(school)
        click_on("Our audit")
        expect(page).to have_content("Our audit")
        expect(page).to have_content("Description of the audit")
        expect(page).to have_link("View all audits")
        expect(page).to have_link(href: rails_blob_path(audit.file))
      end

      it 'doesnt show admin options when viewing audit' do
        visit school_audits_path(school)
        click_on("Our audit")
        expect(page).to_not have_css("#audit-admin-tools")
      end

      it 'shows links to all activities' do
        visit school_audits_path(school)
        click_on("Our audit")
        audit.audit_activity_types.each do |at|
          expect(page).to have_link(at.activity_name, href: activity_type_path(at.activity_type))
        end
      end

      it 'shows links to all actions' do
        visit school_audits_path(school)
        click_on("Our audit")
        audit.audit_intervention_types.each do |at|
          expect(page).to have_link(at.intervention_title, href: intervention_type_path(at.intervention_type))
        end
      end

      it 'shows audit in timeline' do
        visit school_path(school)
        expect(page).to have_content("Received an energy audit")
        expect(page).to have_link(audit.title)
      end

    end
  end

  describe 'as a staff member' do
    let!(:staff) { create(:staff, school: school) }
    let!(:audit) { create(:audit, :with_activity_and_intervention_types, title: "Our audit", description: "Description of the audit", school: school) }

    before(:each) do
      Audits::AuditService.new(school).process(audit)
      sign_in(staff)
      visit school_path(school)
    end

    it 'displays a link to view audits' do
      within '#my_school_menu' do
        click_on 'Energy audits'
      end
      expect(page).to have_content("Energy audits")
    end

    it 'shows audit in timeline' do
      visit school_path(school)
      expect(page).to have_content("Received an energy audit")
      expect(page).to have_link(audit.title)
    end

    it 'lets me view an audit' do
      within '#my_school_menu' do
        click_on 'Energy audits'
      end
      click_on "Our audit"
      expect(page).to have_content("Description of the audit")
    end

  end

  describe 'as pupil' do
    let(:pupil)            { create(:pupil, school: school)}
    let!(:audit) { create(:audit, :with_activity_and_intervention_types, title: "Our audit", description: "Description of the audit", school: school) }

    before(:each) do
      Audits::AuditService.new(school).process(audit)
      sign_in(pupil)
      visit school_path(school)
    end

    it 'displays a link to view audits' do
      within '#my_school_menu' do
        click_on 'Energy audits'
      end
      expect(page).to have_content("Energy audits")
    end

    it 'shows audit in timeline' do
      visit school_path(school)
      expect(page).to have_content("Received an energy audit")
      expect(page).to have_link(audit.title)
    end

    it 'lets me view an audit' do
      within '#my_school_menu' do
        click_on 'Energy audits'
      end
      click_on "Our audit"
      expect(page).to have_content("Description of the audit")
    end

  end

  describe 'as a guest user' do
    let!(:audit) { create(:audit, :with_activity_and_intervention_types, title: "Our audit", description: "Description of the audit", school: school) }

    before(:each) do
      Audits::AuditService.new(school).process(audit)
    end

    it 'shows audit in timeline' do
      visit school_path(school)
      expect(page).to have_content("Received an energy audit")
      expect(page).to_not have_link(audit.title)
    end

    it 'does not let me view list of audits' do
      visit school_audits_path(school)
      expect(page).to have_content("You need to sign in")
    end

    it 'does not let me view an audit' do
      visit school_audit_path(school, audit)
      expect(page).to have_content("You need to sign in")
    end

  end
end
