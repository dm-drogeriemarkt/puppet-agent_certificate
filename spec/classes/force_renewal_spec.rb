# frozen_string_literal: true

require 'spec_helper'

describe 'agent_certificate::force_renewal' do
  let(:pre_condition) do
    [
      'function assert_private(String $message = "") {}',
      'function agent_certificate::renew($agent_certname, $agent_cert_csr, $ttl) { return "FAKECERT" }',
      'include ::agent_certificate::auto_renew',
    ]
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          agent_certificate_csr: 'MY_CSR',
          agent_certificate_path: '/MY/CERT/PATH',
        )
      end

      it { is_expected.to compile }
    end
  end
end
