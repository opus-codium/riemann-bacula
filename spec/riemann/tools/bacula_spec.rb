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
      'Rate'                       => 1.7,
      'Software Compression'       => 0.649,
      'Comm Line Compression'      => 0.0,
      'Snapshot/VSS'               => 'no',
      'Encryption'                 => 'no',
      'Accurate'                   => 'no',
      'Volume name(s)'             => ['CustomersData-7597'],
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
      'Rate'                  => 24615.0,
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

  describe '#extract_backup_level_info' do
    subject { data }

    before { described_class.new.extract_backup_level_info(data) }

    {
      { 'Backup Level' => 'Full' }                                    => { 'Backup Level' => 'Full' },
      { 'Backup Level' => 'Full (upgraded from Differential)' }       => { 'Backup Level' => 'Full', 'Backup Level upgraded from' => 'Differential' },
      { 'Backup Level' => 'Full (upgraded from Incremental)' }        => { 'Backup Level' => 'Full', 'Backup Level upgraded from' => 'Incremental' },
      { 'Backup Level' => 'Differential, since=2003-06-04 00:27:32' } => { 'Backup Level' => 'Differential', 'Backup Level Since' => '2003-06-04 00:27:32' },
      { 'Backup Level' => 'Incremental, since=2020-09-30 02:11:42' }  => { 'Backup Level' => 'Incremental', 'Backup Level Since' => '2020-09-30 02:11:42' },
    }.each do |info, res|
      context "when given #{info.inspect}" do
        let(:data) { info }

        it { is_expected.to eq(res) }
      end
    end
  end

  describe '#extract_client_info' do
    subject { data }

    before { described_class.new.extract_client_info(data) }

    {
      { 'Client' => '"fd.example.com-fd" 9.0.6 (20Nov17) x86_64-pc-linux-gnu,ubuntu,18.04' } => { 'Client' => 'fd.example.com-fd', 'Client Version' => '9.0.6' },
    }.each do |info, res|
      context "when given #{info.inspect}" do
        let(:data) { info }

        it { is_expected.to eq(res) }
      end
    end
  end

  describe '#extract_job_name' do
    subject { data }

    before { described_class.new.extract_job_name(data) }

    {
      { 'Job' => 'nextcloud.2020-07-01_20.05.57_20' } => { 'Job' => 'nextcloud.2020-07-01_20.05.57_20', 'Job Name' => 'nextcloud' },
    }.each do |info, res|
      context "when given #{info.inspect}" do
        let(:data) { info }

        it { is_expected.to eq(res) }
      end
    end
  end

  describe '#extract_source' do
    subject { data }

    before { described_class.new.extract_source(item, data) }

    let(:item) { 'Misc' }

    {
      { 'Misc' => '"foo" (From Client resource)' } => { 'Misc' => 'foo', 'Misc Source' => 'Client' },
      { 'Misc' => '"bar" (From Job resource)' }    => { 'Misc' => 'bar', 'Misc Source' => 'Job' },
      { 'Misc' => '"baz" (From Pool resource)' }   => { 'Misc' => 'baz', 'Misc Source' => 'Pool' },
    }.each do |info, res|
      context "when given #{info.inspect}" do
        let(:data) { info }

        it { is_expected.to eq(res) }
      end
    end
  end

  describe '#extract_time' do
    subject { data }

    before { described_class.new.extract_time(item, data) }

    let(:item) { 'Misc' }

    {
      { 'Misc' => '"foo" 2020-07-01 02:05:00' } => { 'Misc' => 'foo', 'Misc time' => '2020-07-01 02:05:00' },
    }.each do |info, res|
      context "when given #{info.inspect}" do
        let(:data) { info }

        it { is_expected.to eq(res) }
      end
    end
  end

  describe '#parse_duration' do
    subject { described_class.new.parse_duration(s) }

    {
      '1 sec'                    => 1,
      '8 secs'                   => 8,
      '36 secs'                  => 36,
      '3 mins 9 secs'            => 189,
      '1 hour 10 secs'           => 3610,
      '1 hour 12 mins 56 secs'   => 4376,
      '13 hours 35 mins 48 secs' => 48948,
      'not a duration'           => -1,
    }.each do |duration, res|
      context "when given #{duration.inspect}" do
        let(:s) { duration }

        it { is_expected.to eq(res) }
      end
    end
  end

  describe '#parse_integer' do
    subject { described_class.new.parse_integer(s) }

    {
      '12'         => 12,
      '820,234'    => 820_234,
      '1648953913' => 1_648_953_913,
    }.each do |value, res|
      context "when given #{value.inspect}" do
        let(:s) { value }

        it { is_expected.to eq(res) }
      end
    end
  end

  describe '#parse_rate' do
    subject { described_class.new.parse_rate(s) }

    {
      '1.9 KB/s'    => 1.9,
      '2343.4 KB/s' => 2343.4,
    }.each do |value, res|
      context "when given #{value.inspect}" do
        let(:s) { value }

        it { is_expected.to be_within(Float::EPSILON).of(res) }
      end
    end
  end

  describe '#parse_ratio' do
    subject { described_class.new.parse_ratio(s) }

    {
      'None'        => 0.0,
      '61.6% 2.6:1' => 0.616,
      '10.8% 1.1:1' => 0.108,
    }.each do |value, res|
      context "when given #{value.inspect}" do
        let(:s) { value }

        it { is_expected.to be_within(Float::EPSILON).of(res) }
      end
    end
  end

  describe '#parse_size' do
    subject { described_class.new.parse_size(s) }

    {
      '0 (0 B)'                    => 0,
      '24,706,874 (24.70 MB)'      => 24_706_874,
      '821,957,854,696 (821.9 GB)' => 821_957_854_696,
    }.each do |value, res|
      context "when given #{value.inspect}" do
        let(:s) { value }

        it { is_expected.to be_within(Float::EPSILON).of(res) }
      end
    end
  end

  describe '#parse_volumes' do
    subject { described_class.new.parse_volumes(s) }

    {
      ''                           => [],
      'CustomersData-0111'         => %w[CustomersData-0111],
      'Foo-0150|Foo-0151|Foo-0152' => %w[Foo-0150 Foo-0151 Foo-0152],
    }.each do |value, res|
      context "when given #{value.inspect}" do
        let(:s) { value }

        it { is_expected.to eq(res) }
      end
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
