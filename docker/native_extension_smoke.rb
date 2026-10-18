# frozen_string_literal: true

require "nokogiri"
require "pg"
require "google/protobuf"
require "ffi"
require "json"
require "msgpack"
require "bcrypt"
require "webp-ffi"
require "cgi/escape"

# Ruby 4.0 removed the cgi library from the stdlib; only cgi/escape remains and
# `CGI` is no longer auto-loaded. app/services/create_sample_data_service.rb
# depends on CGI.escape, so prove the escape path survives in the shipped image.
raise "CGI.escape is broken" unless CGI.escape("a b") == "a+b"

print "Native extension smoke passed: "
puts ["nokogiri", "pg", "google-protobuf", "ffi", "json", "msgpack", "bcrypt", "webp-ffi", "cgi/escape"].join ", "
