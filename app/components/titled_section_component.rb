# UX component intended to ensure we have consistent, responsive styling for
# page sections that consist of:
#
# - an optional title
# - an optional 1-2 sentence introduction
# - an optional additional link to more information
#
# The default layout is that the intro and link follow on a separate row to the
# title.
#
# These slots are all provided by the calling code to allow for flexibility in
# title/heading sizes and formatting, link formatting, etc.
#
# The component then accepts a slot for the body of the titled section
class TitledSectionComponent < ApplicationComponent
  renders_one :title
  renders_one :intro
  renders_one :link
  renders_one :body

  def render
    body?
  end
end
