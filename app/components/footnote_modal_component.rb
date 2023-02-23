# frozen_string_literal: true

class FootnoteModalComponent < ViewComponent::Base
  renders_one :body_content

  def initialize(title:, modal_id:, modal_dialog_classes: 'modal-lg modal-dialog-centered')
    @title = title
    @modal_id = modal_id
    @modal_dialog_classes = modal_dialog_classes
  end
end
