# frozen_string_literal: true

namespace :school do
  desc 'Update pupil numbers based on establishment data'
  task update_pupil_numbers: :environment do
    Rails.logger = Logger.new($stdout) if Rails.env.development?
    School.active.joins(:establishment).full_school.find_each do |school|
      # GIAS receives information in January from the previous September
      start_date = school.academic_year_for(1.year.ago)&.start_date
      next if start_date.nil?

      Schools::PupilNumberUpdater.new(school)
                                 .update(school.establishment.number_of_pupils,
                                         school.establishment.percentage_fsm,
                                         start_date,
                                         [Schools::PupilNumberUpdater::AUTOMATED_DFE_REASON,
                                          "Imported on #{Date.current}", ''].join('. '))
    end
  end
end
