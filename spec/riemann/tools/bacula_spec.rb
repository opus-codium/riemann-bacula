# frozen_string_literal: true

require 'riemann/tools/bacula'

RSpec.describe Riemann::Tools::Bacula do
  let(:example1_data) do
    {
      'Build OS'              => 'x86_64-pc-linux-gnu debian bullseye/sid',
      'JobId'                 => 14182,
      'Job'                   => 'rdc10235a.2022-09-14_14.26.22_03',
      'Backup Level'          => 'Full (upgraded from Incremental)',
      'Client'                => 'rdc552836.example.com-fd',
      'FileSet'               => 'rdc10235a',
      'Pool'                  => 'CustomersData',
      'Catalog'               => 'MyCatalog',
      'Storage'               => 'rdc7fe7cc.example.com-sd',
      'Scheduled time'        => '14-Sep-2022 14:26:20',
      'Start time'            => '14-Sep-2022 14:26:26',
      'End time'              => '14-Sep-2022 14:26:30',
      'Elapsed time'          => 4,
      'Priority'              => 10,
      'FD Files Written'      => 1,
      'SD Files Written'      => 1,
      'FD Bytes Written'      => 6728,
      'SD Bytes Written'      => 6852,
      'Rate'                  => '1.7 KB/s',
      'Software Compression'  => 0.649,
      'Comm Line Compression' => 0.0,
      'Snapshot/VSS'          => 'no',
      'Encryption'            => 'no',
      'Accurate'              => 'no',
      'Volume name(s)'        => 'CustomersData-7597',
      'Volume Session Id'     => 49,
      'Volume Session Time'   => 1663101659,
      'Last Volume Bytes'     => 236721445,
      'Non-fatal FD errors'   => 0,
      'SD Errors'             => 0,
      'FD termination status' => 'OK',
      'SD termination status' => 'OK',
      'Termination'           => 'Backup OK',

      # Supplements
      'Pool Source'           => 'Job',
      'Catalog Source'        => 'Client',
      'Storage Source'        => 'Pool',
      'Client Version'        => '9.0.6',
      'FileSet time'          => '2022-09-09 02:05:00',
      'Job Name'              => 'rdc10235a',
    }
  end

  describe '#parse' do
    context 'with example-1' do
      subject { described_class.new.parse(text) }

      let(:text) { File.read('spec/fixtures/example-1') }

      it { is_expected.to include(example1_data) }
    end
  end

  describe '#send_events' do
    subject(:instance) { described_class.new }

    before do
      allow(instance).to receive(:report)
      instance.send_events(example1_data)
    end

    it { is_expected.to have_received(:report).with(service: 'backup rdc10235a Full (upgraded from Incremental) fd files written', metric: 1.0, tags: ['bacula']) }
    it { is_expected.to have_received(:report).with(service: 'backup rdc10235a Full (upgraded from Incremental) sd files written', metric: 1.0, tags: ['bacula']) }
    it { is_expected.to have_received(:report).with(service: 'backup rdc10235a Full (upgraded from Incremental) fd bytes written', metric: 6728.0, tags: ['bacula']) }
    it { is_expected.to have_received(:report).with(service: 'backup rdc10235a Full (upgraded from Incremental) sd bytes written', metric: 6852.0, tags: ['bacula']) }
    it { is_expected.to have_received(:report).with(service: 'backup rdc10235a Full (upgraded from Incremental) sd errors', metric: 0.0, tags: ['bacula']) }
    it { is_expected.to have_received(:report).with(service: 'backup rdc10235a termination', state: 'ok', description: 'Backup OK', tags: ['bacula']) }
  end
end
