# Chart Manager - encode and decode chart config
#
#
# Methods tried:
# - Hash.to_params, with and without Active Support ( require 'active_support/core_ext/hash')
# -  URI, .encode_www_form, URI.decode_www_form
# - Rack::Utils.build_query, Rack::Utils.parse_query, Rack::Utils.parse_nested_query
# - Active Support - to_query, CGI::parse
# - .to_yml, URI.encode_www_form, YAML::load
# - .to_json
# - require 'active_support/json/encoding',  ActiveSupport::JSON,encode, JSON.parse(c, {:symbolize_names => true}).with_indifferent_access
#
# this seems to be the best way forward in terms of readability and reversibility
class ChartManager
  include Logging

  # encoding_works, encoded_uri_string = encode_uri(chart_config)
  def encode_uri(chart_config_orig)
    chart_config = chart_config_orig.deep_dup
    chart_config.delete(:min_combined_school_date)
    chart_config.delete(:max_combined_school_date)
    encoded = chart_config.to_params_es.gsub(' ', '+')
    encoded = move_back_to_original_hash_position('timescale', chart_config, encoded)
    encoded = move_back_to_original_hash_position('filter', chart_config, encoded)
    decoded = decode_uri(encoded)
    [chart_config == decoded, encoded]
  end

  # chart_config = decode_uri(uri)
  def decode_uri(uri)
    puts 'Encode:', uri
    chart_config = {}
    uri.split('&').each do |sub_query|
      hash_entry = sub_query.split('=', 2)
      key = hash_entry[0].to_sym
      val = hash_entry[1]
      case key
      when :name
        val = val.gsub('+', ' ').gsub('%2F','/').gsub('%3A',':').gsub('%28','(').gsub('%29',')')
      when :chart1_type, :chart1_subtype, :meter_definition, :series_breakdown, :yaxis_scaling, :inject, :x_axis, :y2_axis
        val = val.to_sym
      when :yaxis_units
        val = val.gsub('%C2%A3', '£').to_sym
      when :y_axis_label
        val = val.gsub('+', ' ').gsub('%C2%A3', '£')
      when :timescale, :filter
        val = val.to_sym
      when :zoomable, :reverse_xaxis
        val = val == 'true' ? true : false
      else
        _all, _type_with_array_index, type_unit, type_value = sub_query.split(/(timescale\[\d+\])\[(\w+)\]=(\d{4}-\d{2}-\d{1,2})/)
        if !type_value.nil?
          chart_config[:timescale] = [] if !chart_config.key?(:timescale)
          chart_config[:timescale].push({ type_unit.to_sym => Date.parse(type_value) })
          next
        end

        _all, type_unit, type_value_0, type_value_1 = sub_query.split(/timescale\[(\w+)\]=(-?\d+)\.\.(-?\d+)/)
        unless type_unit.nil?
          chart_config[:timescale] = { type_unit.to_sym => Range.new(type_value_0.to_i, type_value_1.to_i) }
          next
        end

        _all, _type_with_array_index, type_unit, type_value_0, type_value_1 = sub_query.split(/(timescale\[\d+\])\[(\w+)\]=(-?\d+)\.\.(-?\d+)/)
        unless type_unit.nil?
          chart_config[:timescale] = [] if !chart_config.key?(:timescale)
          chart_config[:timescale].push({ type_unit.to_sym => Range.new(type_value_0.to_i, type_value_1.to_i) })
          next
        end

        _all, _type_with_array_index, type_unit, type_value = sub_query.split(/(timescale\[\d+\])\[(\w+)\]=(-?\d+)/)
        unless type_unit.nil?
          chart_config[:timescale] = [] if !chart_config.key?(:timescale)
          chart_config[:timescale].push({ type_unit.to_sym => type_value.to_i })
          next
        end

        _all, _type_with_array_index, type_unit, type_value = sub_query.split(/(filter\[\d+\])\[(\w+)\]=(-?\d+)/)
        unless type_unit.nil?
          chart_config[:filter] = [] if !chart_config.key?(:filter)
          chart_config[:filter].push({ type_unit.to_sym => type_value.to_i })
          next
        end

        _all, type_unit, type_value = sub_query.split(/filter\[(\w+)\]=(\w+)/)
        unless type_unit.nil?
          chart_config[:filter] = {} if !chart_config.key?(:filter)
          if type_value == 'true' || type_value == 'false'
            chart_config[:filter][type_unit.to_sym] = type_value == 'true' ? true : false
          else
            chart_config[:filter][type_unit.to_sym] = type_value.to_sym
          end
          next
        end

        _all, _type_with_array_index, type_value = sub_query.split(/(series_breakdown\[\d+\])=(\w+)/)
        unless type_value.nil?
          chart_config[:series_breakdown] = [] if !chart_config.key?(:series_breakdown)
          chart_config[:series_breakdown].push(type_value.to_sym)
          next
        end

        puts "Unhandled query #{sub_query}"
        exit
      end
      chart_config[key] = val
    end
    chart_config
  end

  private

  # .to_params, changes order of hash, move it back, so comparison with original
  # doesn't fail - this is relatively cosmetic, but allows comparison to work
  def move_back_to_original_hash_position(type, chart_config, encoded)
    type_index = chart_config.keys.index(type.to_sym)
    unless type_index.nil?
      encoded_array = encoded.split('&')
      encoded_index = encoded_array.index { |x| x.include?(type)}
      copy = encoded_array[encoded_index]
      encoded_array.delete_at(encoded_index)
      encoded_array.insert(type_index,copy)
      encoded = encoded_array.join('&')
    end
    encoded
  end
end

class Hash
  def to_params_es
    params = ''
    stack = []

    each do |k, v|
      if v.is_a?(Hash)
        stack << [k,v]
      elsif v.is_a?(Array)
        stack << [k,Hash.from_array(v)]
      else
        params << "#{k}=#{v}&"
      end
    end

    stack.each do |parent, hash|
      hash.each do |k, v|
        if v.is_a?(Hash)
          stack << ["#{parent}[#{k}]", v]
        else
          params << "#{parent}[#{k}]=#{v}&"
        end
      end
    end

    params.chop!
    params
  end

  def self.from_array(array = [])
    h = Hash.new
    array.size.times do |t|
      h[t] = array[t]
    end
    h
  end
end