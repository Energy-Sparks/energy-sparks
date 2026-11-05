# frozen_string_literal: true

module ScssTaskHelpers
  def self.file_check_write(args, output, output_path)
    args.with_defaults(mode: :generate)
    if args[:mode] == 'check'
      exit File.read(output_path) == output ? 0 : 1 # rubocop:disable Rails/Exit
    else
      File.write(output_path, output)
      puts "Generated #{output_path}" # rubocop:disable Rails/Output -- CLI output without Rails
    end
  end
end
