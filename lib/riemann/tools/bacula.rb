# frozen_string_literal: true

require 'riemann/tools'

module Riemann
  module Tools
    class Bacula
      include Riemann::Tools

      def self.process_stdin
        new.process_stdin
      end

      def process_stdin
        data = parse($stdin.read)
        send_events(data)
      end

      def parse(text)
        data = {}

        text.each_line do |line|
          line.chomp!

          next unless line =~ /\A  ([^:]+):[[:blank:]]+(.*)/

          key = Regexp.last_match(1)
          raw_value = Regexp.last_match(2)

          value = case raw_value
                  when /\A[\d,]+\z/ then raw_value.gsub(',', '').to_i
                  when /\A([\d,]+) \([\d.]+ [KMG]?B\)\z/ then Regexp.last_match(1).gsub(',', '').to_i
                  when /\A(?:(\d+ mins ))?(\d+) secs\z/ then ((Regexp.last_match(1).to_i || 0) * 60) + Regexp.last_match(2).to_i
                  when /\A(\d+\.\d+)% \d+\.\d+:\d+\z/ then Regexp.last_match(1).to_f / 100
                  when 'None' then 0.0
                  when /\|/ then raw_value.split('|')
                  else raw_value
                  end

          if value =~ /\A"(.*)" \(From (Client|Job|Pool) resource\)\z/
            value = Regexp.last_match(1)
            data["#{key} Source"] = Regexp.last_match(2)
          end

          if key == 'Client'
            value =~ /\A"([^"]+)" ([^ ]+)/
            data['Client Version'] = Regexp.last_match(2)
            value = Regexp.last_match(1)
          end

          if key == 'FileSet'
            value =~ /\A"([^"]+)" (\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})/
            data['FileSet time'] = Regexp.last_match(2)
            value = Regexp.last_match(1)
          end

          data[key] = value
        end

        data['Job Name'] = data['Job'].sub(/\.\d{4}-\d{2}-\d{2}_\d{2}\.\d{2}\.\d{2}_\d{2}\z/, '')

        data
      end

      def send_events(data)
        event = {}

        [
          'FD Files Written',
          'SD Files Written',
          'FD Bytes Written',
          'SD Bytes Written',
          'SD Errors',
        ].each do |event_name|
          event = {}
          event[:service] = "backup #{data['Job Name']} #{data['Backup Level']} #{event_name.downcase}"
          event[:metric] = data[event_name].to_f
          event[:tags] = ['bacula']
          report(event)
        end

        event = {}
        event[:service] = "backup #{data['Job Name']} termination"
        event[:state] = case data['Termination']
                        when 'Backup OK' then 'ok'
                        when 'Backup OK -- with warnings' then 'warning'
                        else
                          'critical'
                        end
        event[:description] = data['Termination']
        event[:tags] = ['bacula']

        report(event)
      end
    end
  end
end
