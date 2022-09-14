#!/usr/bin/env ruby
# frozen_string_literal: true

# Redact examples

require 'digest/sha1'

Dir['example-*'].each do |file|
  text = File.read(file)
  text.gsub!(/((?:ns|vps)[0-9][[:alnum:].-]+)(-(?:dir|fd|sd|device))/) { |_match| "rdc#{Digest::SHA1.hexdigest(Regexp.last_match(1))[0..5]}.example.com#{Regexp.last_match(2)}" }
  text.gsub!(/(?:ns|vps)[0-9][[:alnum:]-]+/) { |match| "rdc#{Digest::SHA1.hexdigest(match)[0..5]}" }
  text.gsub!(/ClientBeforeJob "[^"]+"/, 'ClientBeforeJob "REDACTED"')
  File.write(file, text)
end
