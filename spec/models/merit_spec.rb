require 'rails_helper'

describe 'merit rules' do
  include_context "merit badges"

  let(:school_user){ create(:user, :has_school_assigned)}
  let(:school){ school_user.school }

  let(:activity_category) { create :activity_category }
  let(:activity_type) { create(:activity_type, name: "One", activity_category: activity_category, data_driven: true) }
  let(:second_category) { create :activity_category }
  let(:activity_type_2) { create(:activity_type, name: "Two", activity_category: second_category) }

  describe 'badges' do
    describe 'for activities' do
      it "beginner badge for creating an activity" do
        activity_1 = create :activity, school: school, activity_category: activity_category, activity_type: activity_type
        simulate_merit_action('activities#create', user: school_user, target: activity_1)

        school.reload
        expect(school.badges.map(&:name)).to include('beginner')
      end

      it "awards explorer badge for creating one in each category" do
        second_category # preload
        activity_1 = create :activity, school: school, activity_category: activity_category, activity_type: activity_type
        simulate_merit_action('activities#create', user: school_user, target: activity_1)

        school.reload
        expect(school.badges.map(&:name)).to_not include('explorer')

        activity_2 = create :activity, school: school, activity_category: second_category, activity_type: activity_type_2
        school.reload
        simulate_merit_action('activities#create', user: school_user, target: activity_2)
        expect(school.badges.map(&:name)).to include('explorer')
      end

      it "assigns evidence badge when there's a link" do
        activity = create :activity, school: school, description: "This is a test. <a href='http://example.org'>link</a>."
        simulate_merit_action('activities#create', user: school_user, target: activity)

        school.reload
        expect(school.badges.map(&:name)).to include('evidence')
      end

      it "grants badges from the category" do
        activity_type.update!(badge_name: "data-scientist")
        activity  = create :activity, school: school, activity_category: activity_category, activity_type: activity_type
        simulate_merit_action('activities#create', user: school_user, target: activity)

        school.reload
        expect(school.badges.map(&:name)).to include('data-scientist')
      end

      it "assigns reporter badges for counts of activities" do
        18.times do
          create :activity, school: school, activity_category: activity_category, activity_type: activity_type
        end
        activity = create :activity, school: school, activity_category: activity_category, activity_type: activity_type
        simulate_merit_action('activities#create', user: school_user, target: activity)

        school.reload
        expect(school.badges.map(&:name)).to_not include('reporter-20')
        expect(school.badges.map(&:name)).to_not include('reporter-50', 'reporter-100')

        activity = create :activity, school: school, activity_category: activity_category, activity_type: activity_type
        simulate_merit_action('activities#create', user: school_user, target: activity)

        school.reload
        expect(school.badges.map(&:name)).to include('reporter-20')
        expect(school.badges.map(&:name)).to_not include('reporter-50', 'reporter-100')
      end

    end

    ["investigator", "learner", "communicator", "energy-saver", "teamwork"].each do |badge_name|

      context "when awarding #{badge_name}" do
        before(:each) do
          activity_category.badge_name = badge_name
          activity_category.save!
        end

        it "doesn't award for 5 of the same activities" do
          5.times do |i|
            create(:activity, school: school, activity_type: activity_type, activity_category: activity_category )
          end
          #create a further activity to trigger merit
          activity = create :activity, school: school, activity_category: activity_category, activity_type: activity_type
          simulate_merit_action('activities#create', user: school_user, target: activity)

          school.reload
          expect(school.badges.map(&:name)).to_not include(badge_name)
        end

        it "awards #{badge_name} for 5 different activities" do
          5.times do |i|
            activity_type = create(:activity_type, name: i, activity_category: activity_category)
            create(:activity, school: school, activity_type: activity_type, activity_category: activity_category )
          end

          #create a further activity to trigger merit
          activity = create :activity, school: school, activity_category: activity_category, activity_type: activity_type
          simulate_merit_action('activities#create', user: school_user, target: activity)

          school.reload
          expect(school.badges.map(&:name)).to include(badge_name)
        end
      end
    end

    [["autumn-term", "09"], ["spring-term", "01"], ["summer-term", "04"]].each do |badge|
      context "when awarding #{badge[0]}" do

        it "doesn't award #{badge[0]} for activities in same week" do
          8.times do |i|
            create(:activity, school: school, activity_type: activity_type, activity_category: activity_category)
          end
          #create a further activity to trigger merit
          activity = create :activity, school: school, activity_category: activity_category, activity_type: activity_type
          simulate_merit_action('activities#create', user: school_user, target: activity)

          school.reload
          expect(school.badges.map(&:name)).to_not include(badge[0])
        end

        it "awards #{badge[0]} for activities on different weeks" do
          8.times do |i|
            date = Date.parse("#{Date.today.year}-#{badge[1]}-01") + i.weeks
            create(:activity, school: school, activity_type: activity_type, activity_category: activity_category, happened_on: date)
          end
          #create a further activity to trigger merit
          activity = create :activity, school: school, activity_category: activity_category, activity_type: activity_type
          simulate_merit_action('activities#create', user: school_user, target: activity)

          school.reload
          expect(school.badges.map(&:name)).to include(badge[0])
        end
      end
    end

    it "awards graduate badge" do
      50.times do |i|
        date = Date.parse("#{Date.today.year}-01-01") + i.weeks
        create(:activity, school: school, activity_type: activity_type, activity_category: activity_category, happened_on: date)
      end
      #create a further activity to trigger merit
      activity = create :activity, school: school, activity_category: activity_category, activity_type: activity_type
      simulate_merit_action('activities#create', user: school_user, target: activity)

      school.reload
      expect(school.badges.map(&:name)).to include('graduate')
    end
  end

  describe 'points' do
    describe 'for activities' do
      it "doesn't add points for older activities" do
        activity = create :activity, school: school, happened_on: 7.months.ago
        simulate_merit_action('activities#create', user: school_user, target: activity)
        school.reload
        expect(school.points).to eql(0)
      end
    end
  end
end
