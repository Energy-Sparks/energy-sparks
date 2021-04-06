module PartnersHelper
    def list_of_partners(partners)
      return partners.map(&:name).to_sentence
    end

    def list_of_partners_as_links(partners)
      return partners.map {|p| link_to p.name, p.url, target: "_blank", rel: 'noopener'}.to_sentence.html_safe
    end
end
