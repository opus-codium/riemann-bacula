# frozen_string_literal: true

require 'strscan'

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

          data[key] = raw_value
        end

        enhance(data)
      end

      def enhance(data)
        [
          'FD Bytes Written',
          'SD Bytes Written',
          'Last Volume Bytes',
        ].each { |item| data[item] = parse_size(data[item]) }

        [
          'JobId',
          'Priority',
          'Non-fatal FD errors',
          'FD Files Written',
          'SD Files Written',
          'SD Errors',
          'Volume Session Id',
          'Volume Session Time',
        ].each { |item| data[item] = parse_integer(data[item]) }

        [
          'Elapsed time',
        ].each { |item| data[item] = parse_duration(data[item]) }

        [
          'Volume name(s)',
        ].each { |item| data[item] = parse_volumes(data[item]) }

        [
          'Software Compression',
          'Comm Line Compression',
        ].each { |item| data[item] = parse_ratio(data[item]) }

        extract_source('Pool', data)
        extract_source('Catalog', data)
        extract_source('Storage', data)

        extract_time('FileSet', data)

        extract_client_info(data)
        extract_backup_level_info(data)
        extract_job_name(data)

        data
      end

      def extract_backup_level_info(data)
        case data['Backup Level']
        when /\A(Differential|Incremental), since=(.*)\z/
          data['Backup Level'] = Regexp.last_match(1)
          data['Backup Level Since'] = Regexp.last_match(2)
        when /\A(Full) \(upgraded from (Differential|Incremental)\)\z/
          data['Backup Level'] = Regexp.last_match(1)
          data['Backup Level upgraded from'] = Regexp.last_match(2)
        end
      end

      def extract_client_info(data)
        /\A"([^"]+)" ([^ ]+)/.match(data['Client'])

        data['Client'] = Regexp.last_match(1)
        data['Client Version'] = Regexp.last_match(2)
      end

      def extract_job_name(data)
        data['Job Name'] = data['Job'].sub(/\.\d{4}-\d{2}-\d{2}_\d{2}\.\d{2}\.\d{2}_\d{2}\z/, '')
      end

      def extract_source(item, data)
        /\A"([^"]+)" \(From (Client|Job|Pool) resource\)\z/.match(data[item])

        data[item] = Regexp.last_match(1)
        data["#{item} Source"] = Regexp.last_match(2)
      end

      def extract_time(item, data)
        /\A"([^"]+)" (.*)\z/.match(data[item])

        data[item] = Regexp.last_match(1)
        data["#{item} time"] = Regexp.last_match(2)
      end

      def parse_duration(duration)
        s = StringScanner.new(duration)
        res = 0

        until s.eos?
          case
          when s.scan(/\s+/)
            # ignore spaces
          when s.scan(/(\d+) hours?/) then res += s[0].to_i * 3600
          when s.scan(/(\d+) mins?/)  then res += s[0].to_i * 60
          when s.scan(/(\d+) secs?/)  then res += s[0].to_i
          else
            return -1
          end
        end

        res
      end

      def parse_integer(value)
        value.gsub(',', '').to_i
      end

      def parse_ratio(value)
        return 0.0 if value == 'None'

        /\A(\d+\.\d+)% \d+\.\d+:\d+\z/.match(value)
        Regexp.last_match(1).to_f / 100
      end

      def parse_size(value)
        /\A([\d,]+) \([\d.]+ [KMG]?B\)\z/.match(value)
        parse_integer(Regexp.last_match(1))
      end

      def parse_volumes(value)
        value.split('|')
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
