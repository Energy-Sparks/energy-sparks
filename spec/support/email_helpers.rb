# frozen_string_literal: true

module EmailHelpers
  def bootstrap_email_body(email)
    Nokogiri::HTML(email.html_part.decoded).css('.row:nth-of-type(3)')
  end

  def bootstrap_email_body_to_markdown(email)
    ReverseMarkdown.convert(bootstrap_email_body(email))
                   .gsub("\n\n| &nbsp; |\n\n", "\n\n").gsub("| \n", '').gsub(' |', '')
                   .split("\n").map(&:strip).join("\n")
  end
end
