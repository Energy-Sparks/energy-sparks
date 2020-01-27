namespace :after_party do
  desc 'Deployment task: create_partners'
  task create_partners: :environment do
    puts "Running deploy task 'create_partners'"

    # Put your task implementation HERE.
    Partner.transaction do

      images = [
        { name: "bath-hacked.png",  content_type: 'png', url: "http://bathhacked.org/" },
        { name: "theodi.png", content_type: 'png', url: "http://theodi.org/" },
        { name: "ovo.jpg", content_type: 'jpeg', url: "https://www.ovoenergy.com/" },
        { name: "bwce.jpg",  content_type: 'jpeg', url: "http://www.bwce.coop/" },
        { name: "nature-save.jpg",  content_type: 'jpeg', url: "http://www.naturesave.co.uk/the-naturesave-trust/" },
        { name: "beis.png", content_type: 'png', url: "https://www.gov.uk/government/organisations/department-for-business-energy-and-industrial-strategy" },
        { name: "banes.png", content_type: 'png', url: "http://www.bathnes.gov.uk/" },
        { name: "sheffield.png", content_type: 'png', url: "https://www.sheffield.gov.uk" },
        { name: "somersetcc.png",  content_type: 'png', url: "http://www.somerset.gov.uk/" },
        { name: "oxfordshire.jpg",  content_type: 'jpeg', url: "https://www.oxfordshire.gov.uk/" },
        { name: "highland.jpg", content_type: 'jpeg', url: "https://www.highland.gov.uk/" },
      ]

      images.each_with_index do |image, index|
        image_name = image[:name]
        content_type = "image/#{image[:content_type]}"
        partner = Partner.new(position: index + 1, url: image[:url])
        partner.image.attach(io: File.open(Rails.root.join("app/assets/images/logos/#{image_name}")), filename: image_name, content_type: content_type)
        partner.save!
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
