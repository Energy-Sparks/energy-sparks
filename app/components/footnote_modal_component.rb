# frozen_string_literal: true

class FootnoteModalComponent < ApplicationComponent
  renders_one :body_content

  def initialize(title:, modal_id:, modal_dialog_classes: 'modal-lg modal-dialog-centered', **_kwargs)
    super
    @title = title
    @modal_id = modal_id
    @modal_dialog_classes = modal_dialog_classes
  end

  class Link < ApplicationComponent
    attr_reader :modal_id, :href, :title, :remote

    def initialize(modal_id:, href: '#', remote: false, title: '', **_kwargs)
      super
      @modal_id = modal_id
      @href = href
      @title = title
      @remote = remote
    end

    def call
      args = { title: title, 'data-toggle': 'modal', 'data-target': "##{modal_id}", 'data-remote': remote.to_s, class: classes }

      link_to(content, href, args)
    end
  end
end
