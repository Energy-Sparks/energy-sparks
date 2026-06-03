module Layout
  module Cards
    class TestimonialComponent < LayoutComponent
      renders_one :image, ->(**kwargs) do
        Elements::ImageComponent.new(**merge_classes('rounded-xl fit', kwargs))
      end
      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**kwargs.merge({ level: 4 }))
      end
      renders_one :quote, ->(**kwargs) do
        Elements::TagComponent.new(:q, **merge_classes('', kwargs))
      end
      renders_one :name, ->(**kwargs) do
        Elements::TagComponent.new(:span, **merge_classes('text-complement font-weight-bold', kwargs))
      end
      renders_one :role, ->(**kwargs) do
        Elements::TagComponent.new(:span, **merge_classes('text-complement', kwargs))
      end
      renders_one :organisation, ->(**kwargs) do
        Elements::TagComponent.new(:div, **merge_classes('text-complement', kwargs))
      end
      renders_one :case_study, ->(case_study = nil) do
        if case_study
          Elements::ButtonComponent.new(t('components.testimonial.read_case_study'),
            case_study_download_path(case_study), style: :primary, classes: 'mb-1 mr-2')
        end
      end

      def initialize(testimonial: nil, **_kwargs)
        super
        @testimonial = testimonial
      end

      # `#helpers` can't be used during initialization as it depends on the view context that only exists once a ViewComponent is passed to the Rails render pipeline.
      def before_render
        if @testimonial
          with_image(src: cdn_link_url(@testimonial.image))
          with_header(title: @testimonial.title)
          with_quote { @testimonial.quote }
          with_name { @testimonial.name }
          with_role { @testimonial.role }
          with_organisation { @testimonial.organisation }
          with_case_study(@testimonial.case_study)
        end
      end
    end
  end
end
