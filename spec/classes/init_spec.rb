require 'spec_helper'

describe 'puppet_summary' do
  let :node do
    'rspec.puppet.com'
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context 'with all defaults' do
        it { is_expected.to compile.with_all_deps }
      end

      case facts[:os]['name']
      when 'Archlinux'
        context 'on Archlinux' do
          it { is_expected.to contain_user('puppet-summary').with_shell('/usr/bin/nologin') }
        end
      when 'Ubuntu'
        context 'on Ubuntu' do
          it { is_expected.to contain_user('puppet-summary').with_shell('/usr/sbin/nologin') }
        end
      when 'RedHat', 'CentOS'
        context 'on osfamily Redhat' do
          it { is_expected.to contain_user('puppet-summary').with_shell('/sbin/nologin') }
        end
      end
    end
  end
end
