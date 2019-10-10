# puts "Loading #{__FILE__}. Backtrace:"
# puts caller.join("\n")
# puts

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
      def template_5
        nil
      end
      def template_rich_text
        ActionText::RichText.new(body: ActionText::Content.new("<div>Your school is {{position}} in the scoreboard</div>"))
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

    it 'exposes the underlying variables' do
      view_object = TemplateInterpolation.new(object.new).interpolate(:template_1, with: {usage: 'low'})
      expect(view_object.template_variables).to eq({usage: 'low'})
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

    it 'proxies to existing objects' do
      instance = object.new
      view_object = TemplateInterpolation.new(instance, proxy: [:template_2]).interpolate(:template_1, with: {})
      expect(view_object.template_2).to eq("Your school is {{position}} in the leaderboard")
    end

    it 'handles nil templates' do
      instance = object.new
      view_object = TemplateInterpolation.new(instance).interpolate(:template_5, with: {})
      expect(view_object.template_5).to eq("")
    end

    it 'handles rich text' do
      view_object = TemplateInterpolation.new(object.new).interpolate(:template_rich_text, with: { position: 3 })
      expect(view_object.template_rich_text.body).to eq(ActionText::Content.new("<div>Your school is 3 in the scoreboard</div>"))
    end
  end
end
