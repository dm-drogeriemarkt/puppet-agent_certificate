# frozen_string_literal: true

require 'spec_helper'

describe 'agent_certificate' do
  let(:pre_condition) do
    [
      'function assert_private(String $message = "") {}',
    ]
  end
  let(:params) do
    {
      dry_mode: true,
      expiration: 15_552_000,
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
