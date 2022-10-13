# frozen_string_literal: true

require 'riemann/tools/bacula'

RSpec.describe Riemann::Tools::Bacula do
  let(:example1_data) do
    {
      'Build OS'                   => 'x86_64-pc-linux-gnu debian bullseye/sid',
      'JobId'                      => 14182,
      'Job'                        => 'rdc10235a.2022-09-14_14.26.22_03',
      'Backup Level'               => 'Full',
      'Backup Level upgraded from' => 'Incremental',
      'Client'                     => 'rdc552836.example.com-fd',
      'FileSet'                    => 'rdc10235a',
      'Pool'                       => 'CustomersData',
      'Catalog'                    => 'MyCatalog',
      'Storage'                    => 'rdc7fe7cc.example.com-sd',
      'Scheduled time'             => '14-Sep-2022 14:26:20',
      'Start time'                 => '14-Sep-2022 14:26:26',
      'End time'                   => '14-Sep-2022 14:26:30',
      'Elapsed time'               => 4,
      'Priority'                   => 10,
      'FD Files Written'           => 1,
      'SD Files Written'           => 1,
      'FD Bytes Written'           => 6728,
      'SD Bytes Written'           => 6852,
      'Rate'                       => '1.7 KB/s',
      'Software Compression'       => 0.649,
      'Comm Line Compression'      => 0.0,
      'Snapshot/VSS'               => 'no',
      'Encryption'                 => 'no',
      'Accurate'                   => 'no',
      'Volume name(s)'             => 'CustomersData-7597',
      'Volume Session Id'          => 49,
      'Volume Session Time'        => 1663101659,
      'Last Volume Bytes'          => 236721445,
      'Non-fatal FD errors'        => 0,
      'SD Errors'                  => 0,
      'FD termination status'      => 'OK',
      'SD termination status'      => 'OK',
      'Termination'                => 'Backup OK',

      # Supplements
      'Pool Source'                => 'Job',
      'Catalog Source'             => 'Client',
      'Storage Source'             => 'Pool',
      'Client Version'             => '9.0.6',
      'FileSet time'               => '2022-09-09 02:05:00',
      'Job Name'                   => 'rdc10235a',
    }
  end

  let(:example2_data) do
    {
      'Build OS'              => 'x86_64-pc-linux-gnu debian bullseye/sid',
      'JobId'                 => 3257,
      'Job'                   => 'nextcloud.2022-10-07_20.00.00_22',
      'Backup Level'          => 'Differential',
      'Backup Level Since'    => '2022-09-02 20:00:16',
      'Client'                => 'rdcc295d9.example.com-fd',
      'FileSet'               => 'nextcloud',
      'Pool'                  => 'Redacted',
      'Catalog'               => 'MyCatalog',
      'Storage'               => 'rdc593ce8.example.com-sd',
      'Scheduled time'        => '07-Oct-2022 20:00:00',
      'Start time'            => '07-Oct-2022 20:00:15',
      'End time'              => '07-Oct-2022 21:57:12',
      'Elapsed time'          => 7017,
      'Priority'              => 10,
      'FD Files Written'      => 13028,
      'SD Files Written'      => 13028,
      'FD Bytes Written'      => 172723413764,
      'SD Bytes Written'      => 172731259477,
      'Rate'                  => '24615.0 KB/s',
      'Software Compression'  => 0.168,
      'Comm Line Compression' => 0.0,
      'Snapshot/VSS'          => 'no',
      'Encryption'            => 'yes',
      'Accurate'              => 'no',
      'Volume name(s)'        => %w[Redacted-0964 Redacted-0965 Redacted-0966 Redacted-0967 Redacted-0968 Redacted-0969 Redacted-0970 Redacted-0971 Redacted-0972 Redacted-0973 Redacted-0974 Redacted-0975 Redacted-0976 Redacted-0977 Redacted-0978 Redacted-0979 Redacted-0980 Redacted-0981 Redacted-0982 Redacted-0983 Redacted-0984 Redacted-0985 Redacted-0986 Redacted-0987 Redacted-0988 Redacted-0989 Redacted-0990 Redacted-0991 Redacted-0992 Redacted-0993 Redacted-0994 Redacted-0995 Redacted-0996],
      'Volume Session Id'     => 78,
      'Volume Session Time'   => 1661814544,
      'Last Volume Bytes'     => 3273053149,
      'Non-fatal FD errors'   => 0,
      'SD Errors'             => 0,
      'FD termination status' => 'OK',
      'SD termination status' => 'OK',
      'Termination'           => 'Backup OK',

      # Supplements
      'Pool Source'           => 'Job',
      'Catalog Source'        => 'Client',
      'Storage Source'        => 'Pool',
      'Client Version'        => '9.6.7',
      'FileSet time'          => '2019-07-27 20:00:00',
      'Job Name'              => 'nextcloud',
    }
  end

  describe '#parse' do
    context 'with example-1' do
      subject { described_class.new.parse(text) }

      let(:text) { File.read('spec/fixtures/example-1') }

      it { is_expected.to include(example1_data) }
    end

    context 'with example-2' do
      subject { described_class.new.parse(text) }

      let(:text) { File.read('spec/fixtures/example-2') }

      it { is_expected.to include(example2_data) }
    end
  end

  describe '#send_events' do
    subject(:instance) { described_class.new }

    before do
      allow(instance).to receive(:report)
      instance.send_events(example1_data)
    end

    it { is_expected.to have_received(:report).with(service: 'backup rdc10235a Full fd files written', metric: 1.0, tags: ['bacula']) }
    it { is_expected.to have_received(:report).with(service: 'backup rdc10235a Full sd files written', metric: 1.0, tags: ['bacula']) }
    it { is_expected.to have_received(:report).with(service: 'backup rdc10235a Full fd bytes written', metric: 6728.0, tags: ['bacula']) }
    it { is_expected.to have_received(:report).with(service: 'backup rdc10235a Full sd bytes written', metric: 6852.0, tags: ['bacula']) }
    it { is_expected.to have_received(:report).with(service: 'backup rdc10235a Full sd errors', metric: 0.0, tags: ['bacula']) }
    it { is_expected.to have_received(:report).with(service: 'backup rdc10235a termination', state: 'ok', description: 'Backup OK', tags: ['bacula']) }
  end
end
