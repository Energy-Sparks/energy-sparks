# frozen_string_literal: true

class FootnoteModalComponent < ViewComponent::Base
  renders_one :body_content

  def initialize(title:, modal_id:)
    @title = title
    @modal_id = modal_id
  end

  def icon
    helpers.fa_icon('question-circle')
  end
end
