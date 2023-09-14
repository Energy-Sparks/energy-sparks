# frozen_string_literal: true

require "rails_helper"

include ActionView::Helpers

RSpec.describe InfoBarComponent, type: :component do
  pending "add some examples to (or delete) #{__FILE__}"

  it "renders a three colum info bar with an icon, title text, and some optional buttons" do
    expect(
      render_inline(described_class.new(icon: '<i class="fas fa-school fa-3x"></i>'.html_safe, title: 'This is an info bar', buttons: { "Click me" => "http://www.example.com" })).to_html
    ).to include(
      <<~HTML.chomp
        <div class="row">
          <div class="col-md-1 d-flex justify-content-center align-content-center">
            <div class="d-flex align-content-center flex-wrap">
              <i class="fas fa-school fa-3x"></i>
            </div>
          </div>
            <div class="col-md-8">
              This is an info bar
            </div>
              <div class="col-md-3 align-right">
                <a class="btn btn-light btn rounded-pill font-weight-bold" style="height: fit-content;" href="http://www.example.com">Click me</a>
              </div>
        </div>
      HTML
    )
  end
end
