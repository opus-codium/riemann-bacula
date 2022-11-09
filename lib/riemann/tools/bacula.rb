# frozen_string_literal: true

require 'strscan'

require 'riemann/tools'

module Riemann
  module Tools
    class Bacula
      include Riemann::Tools

      opt :client,       'File daemon (%h)',     short: :none, type: :string
      opt :job_name,     'Job name (%n)',        short: :none, type: :string
      opt :backup_level, 'Job Level (%l)',       short: :none, type: :string
      opt :status,       'Job Exit Status (%e)', short: :none, type: :string

      opt :bytes, 'Job Bytes (%b)', short: :none, type: :integer
      opt :files, 'Job Files (%F)', short: :none, type: :integer

      opt :details, 'Send detailed metrics beyond overall status', short: :none, default: true

      def self.process_stdin
        new.process_stdin
      end

      def run
        %i[client job_name backup_level status].each do |name|
          raise("Parameter #{name} is required") unless opts[name]
        end

        data = parse($stdin.read)

        report({
                 host: opts[:client],
                 service: "bacula backup #{opts[:job_name]}",
                 state: bacula_backup_state,
                 job_name: opts[:job_name],
                 backup_level: opts[:backup_level],
                 description: data['Termination'],
               })

        %i[bytes files].each do |metric|
          next unless opts[metric]

          report({
                   host: opts[:client],
                   service: "bacula backup #{opts[:job_name]} #{opts[:backup_level].downcase} #{metric}",
                   metric: opts[metric],
                   job_name: opts[:job_name],
                   backup_level: opts[:backup_level],
                 })
        end

        send_details(data) if options[:details]
      end

      def bacula_backup_state
        case opts[:status]
        when 'OK' then 'ok'
        else
          'critical'
        end
      end

      def parse(text)
        data = {}
        line_continuation = nil

        text.each_line do |line|
          line.chomp!

          if line =~ /\A  ([^:]+):[[:blank:]]+(.*)/
            key = Regexp.last_match(1)
            raw_value = Regexp.last_match(2)

            data[key] = raw_value
          elsif line_continuation
            key = line_continuation
            data[key] += ".#{line}"
          else
            next
          end

          line_continuation = (key if line.length == 998)
        end

        enhance(data)
      end

      def enhance(data)
        # If the message on stdin was trucated, the last item might not make
        # sense.
        data.delete(data.keys.last) if data.keys.last != 'Termination'

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

      def send_details(data)
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
          next unless data[metric]

          report({
                   host: opts[:client],
                   service: "bacula backup #{opts[:job_name]} #{opts[:backup_level].downcase} #{metric.downcase}",
                   metric: data[metric],
                   job_name: opts[:job_name],
                   backup_level: opts[:backup_level],
                 })
        end
      end
    end
  end
end
