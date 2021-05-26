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
    # see https://github.com/skx/puppet-summary/blob/master/API.md
    it 'works on get calls' do
      shell('curl -s http://127.0.0.1:4321/?accept=application/json') do |r|
        expect(r.stdout).to match(%r{null})
      end
    end
    describe curl_command('http://127.0.0.1:4321/', headers: { 'Accept' => 'application/json' }) do
      its(:response_code) { is_expected.to eq(200) }
      its(:exit_status) { is_expected.to eq 0 }
    end
  end
end
