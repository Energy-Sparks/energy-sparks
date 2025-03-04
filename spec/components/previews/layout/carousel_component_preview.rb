module Layout
  class CarouselComponentPreview < ViewComponent::Preview
    def with_single_equivalence
      render Layout::CarouselComponent.new(id: 'ex1') do |carousel|
        carousel.with_equivalence(image_name: 'tree') do |e|
          e.with_title { 'The school consumed XXX kWh' }
          e.with_equivalence { 'This is equivalent to YYYY trees' }
          'This is the content'
        end
      end
    end

    def with_two_equivalences_all_navigation
      render Layout::CarouselComponent.new(id: 'ex2') do |carousel|
        carousel.with_equivalence(image_name: 'tree', classes: 'active') do |e|
          e.with_title { 'The school consumed XXX kWh' }
          e.with_equivalence { 'This is equivalent to YYYY trees' }
          'This is the content'
        end
        carousel.with_equivalence(image_name: 'television') do |e|
          e.with_title { 'The school consumed XXX kWh' }
          e.with_equivalence { 'This is equivalent to watching TV for YYYY hours' }
          'This is the content'
        end
      end
    end

    def with_two_equivalences_no_arrows
      render Layout::CarouselComponent.new(id: 'ex3', show_arrows: false) do |carousel|
        carousel.with_equivalence(image_name: 'tree') do |e|
          e.with_title { 'The school consumed XXX kWh' }
          e.with_equivalence { 'This is equivalent to YYYY trees' }
          'This is the content'
        end
        carousel.with_equivalence(image_name: 'television') do |e|
          e.with_title { 'The school consumed XXX kWh' }
          e.with_equivalence { 'This is equivalent to watching TV for YYYY hours' }
          'This is the content'
        end
      end
    end

    def with_two_equivalences_no_markers
      render Layout::CarouselComponent.new(id: 'ex4', show_markers: false) do |carousel|
        carousel.with_equivalence(image_name: 'tree', classes: 'active') do |e|
          e.with_title { 'The school consumed XXX kWh' }
          e.with_equivalence { 'This is equivalent to YYYY trees' }
          'This is the content'
        end
        carousel.with_equivalence(image_name: 'television', classes: 'carousel-item') do |e|
          e.with_title { 'The school consumed XXX kWh' }
          e.with_equivalence { 'This is equivalent to watching TV for YYYY hours' }
          'This is the content'
        end
      end
    end
  end
end
