# frozen_string_literal: true

class AmrImportJob < ApplicationJob
  queue_as :default

  def perform(config, bucket, filename)
    Amr::Importer.new(config, bucket:).import(filename)
  end
end