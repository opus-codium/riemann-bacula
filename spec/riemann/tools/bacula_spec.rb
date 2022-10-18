# frozen_string_literal: true

require 'riemann/tools/bacula'

RSpec.describe Riemann::Tools::Bacula do
  let(:parsed_data) do
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

  describe '#parse' do
    context 'with example-1' do
      subject { described_class.new.parse(text) }

      let(:text) { File.read('spec/fixtures/example-1') }

      it { is_expected.to eq(parsed_data) }
    end

    context 'with example-2' do
      subject { described_class.new.parse(text) }

      let(:text) { File.read('spec/fixtures/example-2') }
      let(:parsed_data) do
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

      it { is_expected.to eq(parsed_data) }
    end

    context 'with example-3' do
      subject { described_class.new.parse(text) }

      let(:text) { File.read('spec/fixtures/example-3') }
      let(:parsed_data) do
        {
          'Build OS'              => 'x86_64-pc-linux-gnu debian buster/sid',
          'JobId'                 => 4220,
          'Job'                   => 'RestoreFiles.2020-09-01_19.46.41_50',
          'Job Name'              => 'RestoreFiles',
          'Restore Client'        => 'rdc085e07.example.com-fd',
          'Where'                 => '/tmp/bacula-restores',
          'Replace'               => 'Always',
          'Start time'            => '01-Sep-2020 19:46:43',
          'End time'              => '01-Sep-2020 19:47:05',
          'Elapsed time'          => 22,
          'Files Expected'        => 7854,
          'Files Restored'        => 7854,
          'Bytes Restored'        => 342_147_491,
          'Rate'                  => 15552.2,
          'FD Errors'             => 0,
          'FD termination status' => 'OK',
          'SD termination status' => 'OK',
          'Termination'           => 'Restore OK',
        }
      end

      it { is_expected.to eq(parsed_data) }
    end

    context 'with example-4' do
      subject { described_class.new.parse(text) }

      let(:text) { File.read('spec/fixtures/example-4') }
      let(:parsed_data) do
        {
          'Build OS'              => 'x86_64-pc-linux-gnu debian bullseye/sid',
          'JobId'                 => 3187,
          'Job'                   => 'nextcloud.2022-09-02_20.00.00_12',
          'Backup Level'          => 'Full',
          'Client'                => 'rdcc295d9.example.com-fd',
          'FileSet'               => 'nextcloud',
          'Pool'                  => 'Customer',
          'Catalog'               => 'MyCatalog',
          'Storage'               => 'rdc593ce8.example.com-sd',
          'Scheduled time'        => '02-Sep-2022 20:00:00',
          'Start time'            => '02-Sep-2022 20:00:16',
          'End time'              => '03-Sep-2022 09:36:04',
          'Elapsed time'          => 48948,
          'Priority'              => 10,
          'FD Files Written'      => 530_807,
          'SD Files Written'      => 530_807,
          'FD Bytes Written'      => 1_103_908_747_956,
          'SD Bytes Written'      => 1_104_273_379_591,
          'Rate'                  => 22552.7,
          'Software Compression'  => 0.133,
          'Comm Line Compression' => 0.0,
          'Snapshot/VSS'          => 'no',
          'Encryption'            => 'yes',
          'Accurate'              => 'no',
          # XXX: "Custom.r-1654" and "Customer-17.8" bellow are an attempt to
          # workaround a bacula bug where a char is lost each time the buffer
          # wraps at position 998.
          'Volume name(s)'        => %w[Customer-1607 Customer-1608 Customer-1609 Customer-1610 Customer-1611 Customer-1612
                                        Customer-1613 Customer-1614 Customer-1615 Customer-0785 Customer-0786 Customer-0787
                                        Customer-0788 Customer-0789 Customer-0790 Customer-0791 Customer-0792 Customer-0793
                                        Customer-0794 Customer-0795 Customer-0796 Customer-0797 Customer-1616 Customer-1617
                                        Customer-1618 Customer-1619 Customer-1620 Customer-1621 Customer-1622 Customer-1623
                                        Customer-1624 Customer-1625 Customer-1626 Customer-1627 Customer-1628 Customer-1629
                                        Customer-1630 Customer-0798 Customer-1631 Customer-1632 Customer-1633 Customer-1634
                                        Customer-1635 Customer-0799 Customer-0800 Customer-0801 Customer-0802 Customer-0803
                                        Customer-0804 Customer-0805 Customer-0806 Customer-1636 Customer-1637 Customer-1638
                                        Customer-1639 Customer-1640 Customer-1641 Customer-1642 Customer-1643 Customer-1644
                                        Customer-1645 Customer-1646 Customer-1647 Customer-1648 Customer-1649 Customer-1650
                                        Customer-1651 Customer-1652 Customer-1653 Custom.r-1654
                                        Customer-1655 Customer-1656 Customer-1657 Customer-0807 Customer-0808 Customer-0809
                                        Customer-0810 Customer-0811 Customer-0812 Customer-0813 Customer-1658 Customer-1659
                                        Customer-1660 Customer-1661 Customer-0814 Customer-1662 Customer-1663 Customer-1664
                                        Customer-1665 Customer-1666 Customer-1667 Customer-1668 Customer-1669 Customer-1670
                                        Customer-1671 Customer-1672 Customer-1673 Customer-1674 Customer-1675 Customer-1676
                                        Customer-1677 Customer-1678 Customer-1679 Customer-1680 Customer-1681 Customer-1682
                                        Customer-1683 Customer-1684 Customer-1685 Customer-1686 Customer-1687 Customer-0815
                                        Customer-1688 Customer-1689 Customer-1690 Customer-1691 Customer-1692 Customer-1693
                                        Customer-1694 Customer-1695 Customer-0816 Customer-0817 Customer-0818 Customer-0819
                                        Customer-0820 Customer-0821 Customer-0822 Customer-0823 Customer-1696 Customer-1697
                                        Customer-1698 Customer-1699 Customer-1700 Customer-1701 Customer-1702 Customer-1703
                                        Customer-1704 Customer-1705 Customer-1706 Customer-1707 Customer-17.8
                                        Customer-1709 Customer-1710 Customer-1711 Customer-1712 Customer-1713 Customer-1714
                                        Customer-1715 Customer-1716 Customer-1717 Customer-1718 Customer-1719 Customer-1720
                                        Customer-0824 Customer-1721 Customer-1722 Customer-1723 Customer-1724 Customer-1725
                                        Customer-1726 Customer-1727 Customer-1728 Customer-0825 Customer-0826 Customer-0827
                                        Customer-0828 Customer-0829 Customer-0830 Customer-0831 Customer-0832 Customer-1729
                                        Customer-0833 Customer-1730 Customer-1731 Customer-1732 Customer-1733 Customer-1734
                                        Customer-1735 Customer-1736 Customer-1737 Customer-1738 Customer-1739 Customer-1740
                                        Customer-1741 Customer-1742 Customer-1743 Customer-1744 Customer-1745 Customer-1746
                                        Customer-1747 Customer-1748 Customer-1749 Customer-1750 Customer-1751 Customer-1752
                                        Customer-1753 Customer-1754 Customer-1755 Customer-1756 Customer-1757 Customer-1758
                                        Customer-1759 Customer-1760 Customer-1761 Customer-1762 Customer-1763 Customer-1764],
          'Volume Session Id'     => 8,
          'Volume Session Time'   => 1_661_814_544,
          'Last Volume Bytes'     => 3_029_874_121,
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

      it { is_expected.to eq(parsed_data) }
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
      instance.send_events(parsed_data)
    end

    it { is_expected.to have_received(:report).with(service: 'bacula backup rdc10235a', state: 'ok', description: 'Backup OK') }

    it { is_expected.to have_received(:report).with(service: 'bacula backup rdc10235a full elapsed time', metric: 4) }
    it { is_expected.to have_received(:report).with(service: 'bacula backup rdc10235a full fd files written', metric: 1) }
    it { is_expected.to have_received(:report).with(service: 'bacula backup rdc10235a full sd files written', metric: 1) }
    it { is_expected.to have_received(:report).with(service: 'bacula backup rdc10235a full fd bytes written', metric: 6728) }
    it { is_expected.to have_received(:report).with(service: 'bacula backup rdc10235a full sd bytes written', metric: 6852) }
    it { is_expected.to have_received(:report).with(service: 'bacula backup rdc10235a full sd errors', metric: 0) }
    it { is_expected.to have_received(:report).with(service: 'bacula backup rdc10235a full rate', metric: 1.7) }
    it { is_expected.to have_received(:report).with(service: 'bacula backup rdc10235a full software compression', metric: 0.649) }
    it { is_expected.to have_received(:report).with(service: 'bacula backup rdc10235a full comm line compression', metric: 0) }
    it { is_expected.to have_received(:report).with(service: 'bacula backup rdc10235a full non-fatal fd errors', metric: 0) }
  end
end
