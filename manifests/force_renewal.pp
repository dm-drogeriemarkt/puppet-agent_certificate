# @summary
#   This triggers renewal. Should be called from agent_certificate::auto_renew
class agent_certificate::force_renewal {
  assert_private()

  unless $::facts['agent_certificate_csr'] {
    fail 'Certificate renewal requested, but got no CSR (Fact agent_certificate_cs is empty)'
  }

  unless $::facts['agent_certificate_path'] {
    fail 'Certificate renewal requested, but got no path to client certificate (Fact agent_certificate_path is empty)'
  }

  $cert = ::agent_certificate::renew($::trusted['certname'], $::facts['agent_certificate_csr'], $::agent_certificate::expiration)
  file { "${::facts['agent_certificate_path']}.old":
    source => $::facts['agent_certificate_path'],
  } -> file { $::facts['agent_certificate_path']:
    content => $cert,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
