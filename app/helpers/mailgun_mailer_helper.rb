module MailgunMailerHelper
  def add_mg_email_tag(email, tag)
    email.mailgun_headers = { 'X-Mailgun-Tag' => tag }
    email
  end
end
