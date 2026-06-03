# frozen_string_literal: true

namespace :school do
  desc 'Download GIAS data, update Establishments, and try to match existing Schools with Establishments'
  task load_and_match_gias_schools: %i[download_gias_data
                                       import_establishments
                                       match_establishments
                                       assign_diocese
                                       load_and_assign_areas
                                       update_pupil_numbers]
end
