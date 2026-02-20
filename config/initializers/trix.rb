# frozen_string_literal: true

Rails.application.config.after_initialize do
  # until a better fix - see https://github.com/basecamp/trix/issues/1229 for details
  if ActionView::Base.annotate_rendered_view_with_filenames
    module ActionText
      class Attachment
        private

        def trix_attachment_content
          super.gsub(/<!--.*?-->/m, '')
        end
      end
    end
  end
end
