# frozen_string_literal: true

module Layout
  module Cards
    class CaseStudyComponent < LayoutComponent
      renders_one :image, lambda { |**kwargs|
        Elements::ImageComponent.new(**merge_classes('rounded-xl fit', kwargs))
      }
      renders_one :header, lambda { |**kwargs|
        Elements::HeaderComponent.new(**kwargs, level: 4)
      }
      renders_many :tags, lambda { |*args, **kwargs|
        Elements::BadgeComponent.new(*args, classes: 'fw-normal text-uppercase', **kwargs)
      }
      renders_one :description, lambda { |**kwargs|
        Elements::TagComponent.new(:div, **merge_classes('pt-2 pb-4', kwargs))
      }
      renders_one :button, lambda { |case_study = nil|
        Elements::ButtonComponent.new(t('components.testimonial.read_case_study'),
                                      case_study_download_path(case_study), style: :primary, classes: 'mb-1 mr-2')
      }

      def initialize(case_study: nil, **_kwargs)
        super
        @case_study = case_study
      end

      # `#helpers` can't be used during initialization as it depends on the view context
      # that only exists once a ViewComponent is passed to the Rails render pipeline.
      def before_render
        return unless @case_study

        with_image(src: cdn_link_url(@case_study.image))
        with_header(title: @case_study.title)
        with_description { @case_study.description.to_s }
        with_tags(@case_study.tag_list)
        with_button(@case_study)
      end
    end
  end
end
