# frozen_string_literal: true

module EmailHelpers
  def html_email(email)
    Nokogiri::HTML(email.html_part.decoded)
  end

  def html_email_as_markdown(email)
    ReverseMarkdown.convert(html_email(email))
  end

  def bootstrap_email_body(email)
    html_email(email).css('.row:nth-of-type(3)')
  end

  def bootstrap_email_body_to_markdown(email)
    ReverseMarkdown.convert(bootstrap_email_body(email))
                   .gsub("\n\n| &nbsp; |\n\n", "\n\n").gsub("| \n", '').gsub(' |', '')
                   .split("\n").map(&:strip).join("\n")
  end

  def last_email
    expect(ActionMailer::Base.deliveries.length).to eq(1)
    ActionMailer::Base.deliveries.last
  end
end
