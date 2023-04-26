# frozen_string_literal: true

require 'i18n/tasks'
require 'rails_helper'

RSpec.describe I18n do
  let(:i18n) { I18n::Tasks::BaseTask.new }
  let(:missing_keys) { i18n.missing_keys }
  let(:unused_keys) { i18n.unused_keys }
  let(:inconsistent_interpolations) { i18n.inconsistent_interpolations }

  it 'does not have missing keys' do
    expect(missing_keys).to be_empty,
                            "Missing #{missing_keys.leaves.count} i18n keys, run `i18n-tasks missing' to show them"
  end

  it 'does not have unused keys' do
    expect(unused_keys).to be_empty,
                           "#{unused_keys.leaves.count} unused i18n keys, run `i18n-tasks unused' to show them"
  end

  it 'files are normalized' do
    non_normalized = i18n.non_normalized_paths
    error_message = "The following files need to be normalized:\n" \
                    "#{non_normalized.map { |path| "  #{path}" }.join("\n")}\n" \
                    "Please run `i18n-tasks normalize' to fix"
    expect(non_normalized).to be_empty, error_message
  end

  it 'does not have inconsistent interpolations' do
    error_message = "#{inconsistent_interpolations.leaves.count} i18n keys have inconsistent interpolations.\n" \
                    "Run `i18n-tasks check-consistent-interpolations' to show them"
    expect(inconsistent_interpolations).to be_empty, error_message
  end

  it "ensures the 'date.month_names' array follows the conventional format (empty 0th element)" do
    # see https://github.com/rails/rails/blob/main/activesupport/lib/active_support/locale/en.yml
    expect(I18n.t('date.month_names', locale: 'en')).to eq(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'])
    expect(I18n.t('date.month_names', locale: 'cy')).to eq(['', 'Ionawr', 'Chwefror', 'Mawrth', 'Ebrill', 'Mai', 'Mehefin', 'Gorffennaf', 'Awst', 'Medi', 'Hydref', 'Tachwedd', 'Rhagfyr'])
  end

  it "ensures the 'date.abbr_month_names' array follows the conventional format (empty 0th element)" do
    # see https://github.com/rails/rails/blob/main/activesupport/lib/active_support/locale/en.yml
    expect(I18n.t('date.abbr_month_names', locale: 'en')).to eq(['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'])
    expect(I18n.t('date.abbr_month_names', locale: 'cy')).to eq(['', 'Ion', 'Chwe', 'Maw', 'Ebr', 'Mai', 'Meh', 'Gorff', 'Awst', 'Medi', 'Hyd', 'Tach', 'Rhag'])
  end

  it 'ensures the analytics yaml translation files have been synced with the main application with rake i18n:copy_analytics_yaml' do
    analytics_gem_path = `bundle info energy-sparks_analytics --path`.chomp
    analytics_yaml = File.join(analytics_gem_path, 'config', 'locales')
    yaml = Dir["**/*.yml", base: analytics_yaml].reject {|f| f.match /^x-/}.sort
    yaml.each do |yml|
      expect(YAML.load_file(File.join(analytics_gem_path, 'config', 'locales', yml))).to eq(YAML.load_file(Rails.root.join('config', 'locales', 'analytics', yml)))
    end
  end
end
