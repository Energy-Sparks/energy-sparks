class LinkRewrite < ApplicationRecord
  belongs_to :rewriteable, polymorphic: true
  validates_presence_of :source, :target
  validates_uniqueness_of :source, :scope => [:rewriteable_id, :rewriteable_type]
  validates :source, format: { with: URI::DEFAULT_PARSER.make_regexp }, if: proc { |a| a.source.present? }
  validates :target, format: { with: URI::DEFAULT_PARSER.make_regexp }, if: proc { |a| a.target.present? }
end
