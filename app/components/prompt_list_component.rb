class PromptListComponent < ApplicationComponent
  renders_one :title, ->(**kwargs) do
    Elements::HeaderComponent.new(**{ level: 3 }.merge(kwargs))
  end

  renders_one :link
  renders_many :prompts, PromptComponent

  def render?
    prompts?
  end
end
