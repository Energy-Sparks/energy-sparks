namespace :after_party do
  desc 'Deployment task: sha256_action_text_attachment_migrate'
  task sha256_action_text_attachment_migrate: :environment do
    puts "Running deploy task 'sha256_action_text_attachment_migrate'"

    def find_embed_for_element(embeds, element)
      embeds.find do |embed|
        # avoid using embed.filename as that sanitises it so they don't always match
        embed.blob[:filename] == element[:filename] && embed.byte_size.to_s == element[:filesize]
      end
    end

    # https://discuss.rubyonrails.org/t/rails-6-1-7-gives-404-for-actiontext-attachments/80803
    def update_action_text_attachments(rich_text)
      return unless rich_text.embeds.size.positive?

      rich_text.body.fragment.find_all('action-text-attachment').each do |element|
        embed = find_embed_for_element(rich_text.embeds, element)
        if embed.nil? && element[:url].include?('/rails/active_storage')
          puts "missing embed for ActionText::RichText id #{rich_text.id}?"
        end
        next if embed.nil? # non active storage attachment

        old_url = element[:url]
        element[:url] = Rails.application.routes.url_helpers.rails_storage_redirect_url(embed.blob, only_path: true)
        puts "changing #{old_url} to #{element[:url]}"
        element[:sgid] = embed.attachable_sgid
      end

      puts "updating action-text-attachments in ActionText::RichText id #{rich_text.id} to #{rich_text.body}"
      rich_text.update_column :body, rich_text.body.to_s
    end

    ActionText::RichText.where.not(body: nil).find_each do |rich_text|
      update_action_text_attachments(rich_text)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
