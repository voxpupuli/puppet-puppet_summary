require 'spec_helper_acceptance'

describe 'puppet_summary' do
  context 'with all defaults' do
    let(:pp) do
      'include puppet_summary'
    end

    it 'works idempotently with no errors' do
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('puppet-summary.service') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
    describe port(4321) do
      it { is_expected.to be_listening.with('tcp') }
    end
    describe process('puppet-summary') do
      its(:args) { is_expected.to match %r{\ -host\ 127.0.0.1\ -port\ 4321} }
    end
  end
end
