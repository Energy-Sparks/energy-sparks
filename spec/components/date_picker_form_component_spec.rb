# frozen_string_literal: true

require "rails_helper"

RSpec.describe DatePickerFormComponent, type: :component do
  it "renders a datepicker form component" do
    expect(
      ActionController::Base.render DatePickerFormComponent.new(form: OpenStruct.new(object_name: 'job'), field_name: :start_date, value: '01/12/2022')
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
