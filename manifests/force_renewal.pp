# @summary
#   This triggers renewal. Should be called from agent_certificate::auto_renew
class agent_certificate::force_renewal {
  assert_private()

  $agent_cert_csr = $::facts['agent_certificate_csr']
  $agent_cert_path = $::facts['agent_certificate_path']
  $agent_certname = $::trusted['certname']

  unless $agent_cert_csr {
    fail 'Certificate renewal requested, but got no CSR (Fact agent_certificate_cs is empty)'
  }

  unless $agent_cert_path {
    fail 'Certificate renewal requested, but got no path to client certificate (Fact agent_certificate_path is empty)'
  }

  $cert = ::agent_certificate::renew($agent_certname, $agent_cert_csr, $::agent_certificate::auto_renew::expiration)
  file { "${agent_cert_path}.old":
    source => $agent_cert_path,
  } -> file { $agent_cert_path:
    content => $cert,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
