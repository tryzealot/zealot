# frozen_string_literal: true

require "nokogiri"
require "pg"
require "google/protobuf"
require "ffi"
print "Native extension smoke passed: "
puts ["nokogiri", "pg", "google-protobuf", "ffi"].join ", "
