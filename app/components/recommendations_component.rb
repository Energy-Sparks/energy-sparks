# frozen_string_literal: true

class RecommendationsComponent < ApplicationComponent
  attr_reader :title, :description, :limit, :limit_lg

  def initialize(title: nil, description: nil, tasks: [], limit: 4, **_kwargs)
    super
    @title = title
    @description = description
    @limit = limit
    @tasks = tasks
  end

  def link_text(task)
    task.public_type == :activity ? t('common.view_pupil_activity') : t('common.view_adult_action')
  end

  def render?
    @tasks.any?
  end
end
