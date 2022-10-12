class LinkRewrite < ApplicationRecord
  belongs_to :rewriteable, polymorphic: true
  validates_presence_of :source, :target
  validates_uniqueness_of :source, :scope => [:rewriteable_id, :rewriteable_type]
end
