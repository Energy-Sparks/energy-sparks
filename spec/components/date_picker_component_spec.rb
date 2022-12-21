# frozen_string_literal: true

require "rails_helper"
include ActionView::Helpers::FormHelper

RSpec.describe DatePickerComponent, type: :component do
  it "renders a datepicker form component" do
    form = ActionView::Helpers::FormBuilder.new(:job, OpenStruct.new(start_date: nil), nil, {})
    expect(
      render_inline(described_class.new(form: form, field: :start_date, label: 'This is the Start Date label')).to_html
    ).to include(
      '<input class="form-control datetimepicker-input" data-target="#datetimepickerform_start_date" type="text" name="job[start_date]" id="job_start_date">'
    ).and include(
      '<label class="form-label" for="job_start_date">This is the Start Date label</label>'
    )
  end
end
