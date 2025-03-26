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
        Elements::TagComponent.new(:q, **merge_classes('small', kwargs))
      end
      renders_one :name, ->(**kwargs) do
        Elements::TagComponent.new(:span, **merge_classes('small text-darker font-weight-bold', kwargs))
      end
      renders_one :role, ->(**kwargs) do
        Elements::TagComponent.new(:span, **merge_classes('small text-darker', kwargs))
      end
      renders_one :organisation, ->(**kwargs) do
        Elements::TagComponent.new(:div, **merge_classes('small text-darker', kwargs))
      end
      renders_one :case_study, ->(case_study) do
        Elements::ButtonComponent.new(t('home.testimonials.read_case_study'),
          case_study_download_path(case_study), style: :primary, classes: 'mb-1 mr-2')
      end
    end
  end
end
