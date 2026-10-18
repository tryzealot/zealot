# frozen_string_literal: true

# Invariant: every installed gem is the ruby platform (built/generated
# locally) or a musl-native variant (*-linux-musl). Anything else is a
# foreign artifact: -gnu binaries can never load on musl, and legacy
# bare-Linux binaries (e.g. x86_64-linux) are glibc-linked yet still match
# the local platform.
def valid_platform?(platform)
  platform == "ruby" || platform.end_with?("-linux-musl")
end

def platform_check_offenders(specs)
  specs.reject { |spec| valid_platform?(spec.platform.to_s) }
       .map { |spec| "#{spec.name} #{spec.version} #{spec.platform}" }
end

specs = Bundler.load.specs
offenders = platform_check_offenders(specs)

if offenders.empty?
  puts "Platform assertion passed: #{specs.size} specs installed, all ruby or *-linux-musl"
else
  warn "Platform assertion FAILED: #{offenders.size} gem(s) are neither ruby nor musl platform:"
  offenders.sort.each { |offender| warn "  #{offender}" }
  exit 1
end
