# frozen_string_literal: true

require 'strscan'

require 'riemann/tools'

module Riemann
  module Tools
    class Bacula
      include Riemann::Tools

      opt :details, 'Send detailed metrics beyond overall status', default: true

      def self.process_stdin
        new.process_stdin
      end

      def run
        options
        data = parse($stdin.read)
        send_events(data) if data
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

        return nil unless valid?(data)

        enhance(data)
      end

      def valid?(data)
        %w[
          Job
          Termination
        ].all? { |key| data.key?(key) }
      end

      def enhance(data)
        {
          parse_size: [
            'FD Bytes Written',
            'SD Bytes Written',
            'Last Volume Bytes',
            'Bytes Restored',
          ],
          parse_integer: [
            'JobId',
            'Priority',
            'Non-fatal FD errors',
            'FD Files Written',
            'FD Errors',
            'SD Files Written',
            'SD Errors',
            'Volume Session Id',
            'Volume Session Time',
            'Files Expected',
            'Files Restored',
          ],
          parse_duration: [
            'Elapsed time',
          ],
          parse_volumes: [
            'Volume name(s)',
          ],
          parse_rate: [
            'Rate',
          ],
          parse_ratio: [
            'Software Compression',
            'Comm Line Compression',
          ],
        }.each do |parser, keys|
          keys.each do |key|
            data[key] = send(parser, data[key]) if data[key]
          end
        end

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
        return unless /\A"([^"]+)" ([^ ]+)/.match(data['Client'])

        data['Client'] = Regexp.last_match(1)
        data['Client Version'] = Regexp.last_match(2)
      end

      def extract_job_name(data)
        data['Job Name'] = data['Job'].sub(/\.\d{4}-\d{2}-\d{2}_\d{2}\.\d{2}\.\d{2}_\d{2}\z/, '')
      end

      def extract_source(item, data)
        return unless /\A"([^"]+)" \(From (Client|Job|Pool) resource\)\z/.match(data[item])

        data[item] = Regexp.last_match(1)
        data["#{item} Source"] = Regexp.last_match(2)
      end

      def extract_time(item, data)
        return unless /\A"([^"]+)" (.*)\z/.match(data[item])

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

      def parse_rate(value)
        %r{\A(\d+\.\d+) KB/s\z}.match(value)
        Regexp.last_match(1).to_f
      end

      def parse_ratio(value)
        return 0.0 if value == 'None'

        /\A(\d+\.\d+)% \d+\.\d+:\d+\z/.match(value)
        Regexp.last_match(1).to_f / 100
      end

      def parse_size(value)
        raise ArgumentError, %(Cannot parse size "#{value}") unless /\A([\d,]+) \([\d.]+ [KMGT]?B\)\z/.match(value)

        parse_integer(Regexp.last_match(1))
      end

      def parse_volumes(value)
        value.split('|')
      end

      def send_events(data)
        event = {}
        event[:service] = "bacula backup #{data['Job Name']}"
        event[:state] = case data['Termination']
                        when /\A(Backup|Restore) OK\z/ then 'ok'
                        when 'Backup OK -- with warnings' then 'warning'
                        else
                          'critical'
                        end
        event[:description] = data['Termination']
        report(event)

        return unless options[:details]

        [
          'Elapsed time',
          'FD Files Written',
          'SD Files Written',
          'FD Bytes Written',
          'SD Bytes Written',
          'SD Errors',
          'Rate',
          'Software Compression',
          'Comm Line Compression',
          'Non-fatal FD errors',
        ].each do |metric|
          event = {}
          event[:service] = "bacula backup #{data['Job Name']} #{data['Backup Level'].downcase} #{metric.downcase}"
          event[:metric] = data[metric]
          report(event)
        end
      end
    end
  end
end
