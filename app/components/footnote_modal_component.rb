# frozen_string_literal: true

class FootnoteModalComponent < ViewComponent::Base
  renders_one :body_content

  def initialize(title:)
    @title = title
  end

  def icon
    helpers.fa_icon('question-circle')
  end

  def modal_id
    'footnote-modal-' + object_id.to_s
  end
end
