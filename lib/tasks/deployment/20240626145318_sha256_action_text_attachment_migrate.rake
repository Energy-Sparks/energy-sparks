namespace :after_party do
  desc 'Deployment task: sha256_action_text_attachment_migrate'
  task sha256_action_text_attachment_migrate: :environment do
    puts "Running deploy task 'sha256_action_text_attachment_migrate'"

    # https://discuss.rubyonrails.org/t/rails-6-1-7-gives-404-for-actiontext-attachments/80803
    def refresh_trix(trix)
      return unless trix.embeds.size.positive?

      trix.body.fragment.find_all('action-text-attachment').each do |node|
        embed = trix.embeds.find do |attachment|
          attachment.filename.to_s == node['filename'] && attachment.byte_size.to_s == node['filesize']
        end
        next if embed.nil? # non active storage attachment

        node.attributes['url'].value =
          Rails.application.routes.url_helpers.rails_storage_redirect_url(embed.blob, only_path: true)
        node.attributes['sgid'].value = embed.attachable_sgid
      end

      trix.update_column :body, trix.body.to_s
    end

    ActionText::RichText.where.not(body: nil).find_each do |trix|
      refresh_trix(trix)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
