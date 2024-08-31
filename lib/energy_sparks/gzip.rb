# frozen_string_literal: true

module EnergySparks
  module Gzip
    def self.gzip(data)
      io = StringIO.new
      Zlib::GzipWriter.wrap(io) { |gzip| gzip.write(data) }
      io.string
    end

    def self.gunzip(data)
      Zlib::GzipReader.new(StringIO.new(data)).read
    end
  end
end
