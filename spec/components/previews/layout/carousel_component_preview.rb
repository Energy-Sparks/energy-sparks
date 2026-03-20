module Layout
  class CarouselComponentPreview < ViewComponent::Preview
    # @param show_arrows select { choices: [side, bottom, false] }
    # @param show_markers toggle
    # @param theme select { choices: [nil, dark, accent, light, pale] }
    # @param rounded toggle
    # @param bs5 toggle
    def with_equivalences(show_arrows: :bottom, show_markers: true, theme: nil, rounded: false, bs5: false)
      render_carousel(
        show_arrows: show_arrows,
        show_markers: show_markers,
        theme: theme,
        rounded: rounded,
        bs5: bs5
      ) do |carousel|
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

    # @param show_arrows select { choices: [side, bottom, nil, false] }
    # @param show_markers toggle
    # @param theme select { choices: [nil, dark, accent, light, pale] }
    # @param rounded toggle
    # @param bs5 toggle
    def with_grid(show_arrows: :side, show_markers: false, theme: :accent, rounded: true, bs5: false)
      render_carousel(
        show_arrows: show_arrows,
        show_markers: show_markers,
        theme: theme,
        rounded: rounded,
        bs5: bs5
      ) do |carousel|
        carousel.with_grid(cols: 2) do |grid|
          grid.with_image(src: 'laptop.jpg', classes: 'w-100 rounded')

          grid.with_feature_card do |feature|
            feature.with_header(title: 'Laptop header')
            feature.with_description { 'Laptop description' }
            feature.with_button('Primary', '/', style: :primary)
          end
        end

        carousel.with_grid(cols: 2) do |grid|
          grid.with_feature_card do |feature|
            feature.with_header(title: 'Whiteboard header')
            feature.with_description { 'Whiteboard description' }
            feature.with_button('Primary', '/', style: :primary)
          end

          grid.with_image(src: 'whiteboard.jpg', classes: 'w-100 rounded')
        end
      end
    end

    private

    def render_carousel(show_arrows:, show_markers:, theme:, rounded:, bs5:)
      classes = []
      classes << 'rounded p-4' if rounded

      render Layout::CarouselComponent.new(
        id: 'preview',
        show_arrows: show_arrows,
        show_markers: show_markers,
        theme: theme&.to_sym,
        bs5: bs5,
        classes: classes.join(' ')
      ) do |carousel|
        yield carousel
      end
    end
  end
end
