module TodosHelper
  def select_task(type, name, idx = 0)
    within "##{type.to_s.dasherize}-todos" do
      all_selects = all('select')

      chosen_select = all_selects[idx]
      chosen_select.find(:xpath, ".//option[contains(text(), '#{name}')]").select_option
    end
  end
end

RSpec.configure do |config|
  config.include TodosHelper
end
