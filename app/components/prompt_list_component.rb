class PromptListComponent < ApplicationComponent
  renders_one :title
  renders_one :link
  renders_many :prompts, PromptComponent

  def render?
    prompts?
  end
end
