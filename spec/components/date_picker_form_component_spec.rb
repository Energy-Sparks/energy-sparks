# frozen_string_literal: true

require "rails_helper"

RSpec.describe DatePickerFormComponent, type: :component do
  let(:value)         { '01/12/2022' }
  let(:params)    {
    {
    form: OpenStruct.new(object_name: 'job'),
    field_name: :start_date,
    value: value,
    }
  }

  let(:component) { DatePickerFormComponent.new(**params) }

  let(:html) {
    render_inline(component)
  }

  it "renders expected field" do
    expect(html).to have_css('#job_start_date')
  end

  it "renders expected value" do
    expect(html).to have_field('job[start_date]', with: value)
  end

  context 'with empty value' do
    let(:value) { nil }
    it 'defaults to today' do
      expect(html).to have_field('job[start_date]', with: Time.zone.today.strftime("%d/%m/%Y"))
    end

    context 'and a default supplied' do
      let(:params)    {
        {
        form: OpenStruct.new(object_name: 'job'),
        field_name: :start_date,
        value: value,
        default_if_nil: '',
        hint: ''
        }
      }
      it 'uses that default' do
        expect(html).to have_field('job[start_date]', with: '')
      end
    end
  end

  it "renders a datepicker form component" do
    expect(
      ActionController::Base.render component
    ).to eq(
      <<~HTML.chomp
        <div class="input-group date" id="datepickerformcomponent_start_date" data-target-input="nearest">
          <input class="form-control datetimepicker-input" data-target="#datepickerformcomponent_start_date" type="text" name="job[start_date]" id="job_start_date" value="01/12/2022" />
          <div class="input-group-append" data-target="#datepickerformcomponent_start_date" data-toggle="datetimepicker">
            <div class="input-group-text"><i class="fa fa-calendar"></i></div>
          </div>
        </div>

      HTML
    )
  end
end
