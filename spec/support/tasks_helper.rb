module TasksHelper
  def select_task(type, name, idx = 0)
    within "#tasklist-#{type.to_s.dasherize}s" do
      all_selects = all('select')

      chosen_select = all_selects[idx]
      chosen_select.find(:xpath, ".//option[contains(text(), '#{name}')]").select_option
    end
  end
end

RSpec.configure do |config|
  config.include TasksHelper
end
