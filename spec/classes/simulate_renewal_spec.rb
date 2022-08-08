# frozen_string_literal: true

require 'spec_helper'

describe 'agent_certificate::simulate_renewal' do
  let(:pre_condition) do
    [
      'function assert_private(String $message = "") {}',
    ]
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
