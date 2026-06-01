# frozen_string_literal: true

module Admin
  class IssueTagsController < AdminController
    load_and_authorize_resource :issue_tag

    def edit; end

    # rubocop:disable Rails/I18nLocaleTexts

    def create
      if @issue_tag.save
        redirect_to admin_issue_tags_path, notice: 'Issue tag was successfully created'
      else
        render :new
      end
    end

    def update
      if @issue_tag.update(issue_tag_params)
        redirect_to admin_issue_tags_path, notice: 'Issue tag was successfully updated'
      else
        render :edit
      end
    end

    def destroy
      if @issue_tag.destroy
        redirect_to admin_issue_tags_path, notice: 'Issue tag was successfully deleted'
      else
        redirect_to admin_issue_tags_path, notice: @issue_tag.errors.full_messages.to_sentence
      end
    end

    # rubocop:enable Rails/I18nLocaleTexts

    private

    def issue_tag_params
      params.expect(issue_tag: [:label])
    end
  end
end
