# frozen_string_literal: true

require "rails_helper"
include ActionView::Helpers::FormHelper

RSpec.describe DatePickerFormComponent, type: :component do
  it "renders a datepicker form component" do
  #   form = ActionView::Helpers::FormBuilder.new(:job, OpenStruct.new(start_date: nil), nil, {})
  #   expect(
  #     ActionController::Base.render DatePickerFormComponent.new(form: form, field: :start_date, label: 'This is the Start Date label')
  #   ).to eq(
  #     <<~HTML.chomp
  #       <div class="form-group">
  #         <label class="form-label" for="job_start_date">This is the Start Date label</label>
  #         <div class="input-group date" id="datetimepickerform_start_date" data-target-input="nearest">
  #           <input class="form-control datetimepicker-input" data-target="#datetimepickerform_start_date" type="text" name="job[start_date]" id="job_start_date" />
  #           <div class="input-group-append" data-target="#datetimepickerform_start_date" data-toggle="datetimepicker">
  #             <div class="input-group-text"><i class="fa fa-calendar"></i></div>
  #           </div>
  #         </div>
  #       </div>

  #       <script type="text/javascript">
  #         $(function () {
  #           $('#datetimepickerform_start_date').datetimepicker({
  #             format: 'DD/MM/YYYY',
  #             allowInputToggle: true,
  #             locale: moment.locale()
  #           });
  #         });
  #       </script>

  #     HTML
  #   )
  end
end
