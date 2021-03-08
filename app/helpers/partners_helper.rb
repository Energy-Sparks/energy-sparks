module PartnersHelper
    def list_of_partners(partners)
      return partners.map(&:name).to_sentence
    end

    def list_of_partners_as_links(partners)
      return partners.map {|p| link_to p.name, p.url, target: "_new" }.to_sentence
    end
end
