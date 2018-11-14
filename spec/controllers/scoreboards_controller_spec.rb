require 'rails_helper'

RSpec.describe ScoreboardsController, type: :controller do

  let(:scoreboard){ create(:scoreboard) }

  describe 'GET #show' do
    context "as a school administrator" do
      let(:group){ create(:school_group, scoreboard: scoreboard) }
      let(:school) { create :school, enrolled: true, school_group: group }

      before(:each) do
        sign_in_user(:school_user, school.id)
      end

      it 'doesnt award a badge if school has zero points' do
        get :show, params: {id: scoreboard.to_param}
        expect(school.badges.length).to eql(0)
      end

      context 'where the school has 20 points' do
        before do
          school.add_points(20)
        end

        it 'grants the a badge if school has 10 points' do
          get :show, params: {id: scoreboard.to_param}
          school.reload
          expect(school.badges.length).to eql(1)
          expect(school.badges.first.name).to eql("player")
        end

        it 'does not award a badge if viewing the scoreboard for a different school' do
          other_scoreboard = create(:scoreboard)
          get :show, params: {id: other_scoreboard.to_param}
          school.reload
          expect(school.badges.length).to eql(0)
        end

      end
    end
  end
end
