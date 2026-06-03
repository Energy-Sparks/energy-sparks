namespace :after_party do
  desc 'Deployment task: support_page_placeholders'
  task support_page_placeholders: :environment do
    puts "Running deploy task 'support_page_placeholders'"
    category = nil
    page = nil

    CSV.foreach(File.join(__dir__, 'cms.csv'), headers: true) do |row|
      category_title = row['Category']
      page_title = row['Page']
      audience = row['Audience']
      section_title = row['Section']

      category = Cms::Category.create!(title: category_title, description: 'Placeholder') if category&.title != category_title

      if page&.title != page_title
        page = category.pages.create!(
          title_en: page_title,
          description: 'Placeholder',
          audience: audience.to_sym
        )
      end
      page.sections.create!(title: section_title)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
