module Layout
  class GridComponentPreview < ViewComponent::Preview
    def with_2_cols
      render Layout::GridComponent.new(
        id: '2-cols',
        cols: 2,
        cell_classes: 'mb-4',
        component_classes: %w[h-100]
      ) do |grid|
        grid.with_prompt_list do |prompt_list|
          prompt_list.with_title { 'With prompt list' }
          prompt_list.with_prompt(fuel_type: :gas, status: :positive) { 'Gas positive prompt' }
          prompt_list.with_prompt(fuel_type: :electricity, status: :negative) { 'Electricity negative prompt' }
        end
        grid.with_block cell_classes: 'pb-2', classes: %w[p-4 bg-light rounded] do
          'With block'
        end
      end
    end

    def with_3_cols
      render Layout::GridComponent.new(
        id: '3-cols',
        cols: 3,
        cell_classes: 'mb-2',
        component_classes: %w[bg-light p-4 rounded text-center h-100]
      ) do |grid|
        grid.with_image src: 'laptop.jpg', classes: 'w-100'
        grid.with_block do
          'With block'
        end
        grid.with_block do
          'With block'
        end
      end
    end

    def with_4_cols
      render Layout::GridComponent.new(
        id: '4-cols',
        cols: 4,
        cell_classes: 'pb-4',
        component_classes: %w[h-100 p-4 rounded]
      ) do |grid|
        grid.with_block classes: 'bg-gas-light' do
          'With block'
        end
        grid.with_block classes: 'text-center bg-electric-light' do
          'With block: text-centre'
        end
        grid.with_block classes: 'text-center bg-storage-light' do
          'With block: text-centre'
        end
        grid.with_block classes: 'text-right bg-solar-light' do
          'With block: text-right'
        end
      end
    end
  end
end
