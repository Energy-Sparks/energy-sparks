require 'rails_helper'

describe TemplateInterpolation do


  let(:object) do
    Class.new do
      def template_1
        "Your energy usage is quite {{usage}}"
      end
      def template_2
        "Your school is {{position}} in the leaderboard"
      end
      def template_3
        "Your school is {{position}} in the scoreboard"
      end
      def template_4
        "Your school spent {{gbp}}"
      end
    end
  end

  describe 'variables' do

    it 'returns the variables used in the template' do
      variables = TemplateInterpolation.new(object.new).variables(:template_1)
      expect(variables).to eq(['usage'])
    end

    it 'returns the variables from multiple templates' do
      variables = TemplateInterpolation.new(object.new).variables(:template_1, :template_2)
      expect(variables).to eq(['usage', 'position'])
    end

    it 'only returns unique variables' do
      variables = TemplateInterpolation.new(object.new).variables(:template_1, :template_2, :template_3)
      expect(variables).to eq(['usage', 'position'])
    end

    it 'changes gbp for £' do
      variables = TemplateInterpolation.new(object.new).variables(:template_4)
      expect(variables).to eq(['£'])
    end

  end

  describe 'interpolation' do

    it 'creates objects with the specified interfaces that have been templated' do
      view_object = TemplateInterpolation.new(object.new).interpolate(:template_1, with: {usage: 'low'})
      expect(view_object.template_1).to eq('Your energy usage is quite low')
      expect(view_object.methods).to_not include(:template_2)
    end

    it 'interpolates multiple fields' do
      view_object = TemplateInterpolation.new(object.new).interpolate(:template_1, :template_2, with: {usage: 'low', position: 3})
      expect(view_object.template_1).to eq('Your energy usage is quite low')
      expect(view_object.template_2).to eq('Your school is 3 in the leaderboard')
    end

    it 'interpolates from string keyed hashes' do
      view_object = TemplateInterpolation.new(object.new).interpolate(:template_1, with: {'usage': 'low'})
      expect(view_object.template_1).to eq('Your energy usage is quite low')
    end


    it 'leaves missing variables blank' do
      view_object = TemplateInterpolation.new(object.new).interpolate(:template_1, with: {})
      expect(view_object.template_1).to eq('Your energy usage is quite ')
    end

    it 'sets the object' do
      instance = object.new
      view_object = TemplateInterpolation.new(instance, with_objects: {alert: instance}).interpolate(:template_1, with: {})
      expect(view_object.alert).to eq(instance)
    end

    it 'sets the object' do
      instance = object.new
      view_object = TemplateInterpolation.new(instance, proxy: [:template_2]).interpolate(:template_1, with: {})
      expect(view_object.template_2).to eq("Your school is {{position}} in the leaderboard")
    end
  end
end
