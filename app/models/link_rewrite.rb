# == Schema Information
#
# Table name: link_rewrites
#
#  created_at       :datetime         not null
#  id               :bigint(8)        not null, primary key
#  rewriteable_id   :bigint(8)
#  rewriteable_type :string
#  source           :string
#  target           :string
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_link_rewrites_on_rewriteable_type_and_rewriteable_id  (rewriteable_type,rewriteable_id)
#
class LinkRewrite < ApplicationRecord
  belongs_to :rewriteable, polymorphic: true
  validates :source, :target, presence: true
  validates :source, uniqueness: { scope: %i[rewriteable_id rewriteable_type] }
  validates :source, format: { with: URI::DEFAULT_PARSER.make_regexp }, if: proc { |a| a.source.present? }
  validates :target, format: { with: URI::DEFAULT_PARSER.make_regexp }, if: proc { |a| a.target.present? }

  def escaped_source
    CGI.escape_html(source)
  end
end
