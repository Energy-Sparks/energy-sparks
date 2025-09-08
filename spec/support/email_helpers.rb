# frozen_string_literal: true

module EmailHelpers
  def email_html_text(email)
    Capybara.string(email.html_part.decoded)
            .text.delete("\u00A0").each_line.map(&:strip).reject(&:empty?).join("\n")
  end
end
