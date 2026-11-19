# frozen_string_literal: true

class BasePreview < ActionMailer::Preview
  private

  def locale
    @params['locale'].presence || 'en'
  end
end
