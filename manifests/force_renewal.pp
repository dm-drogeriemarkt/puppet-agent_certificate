# @summary
#   This triggers renewal. Should not be called directly
class agent_certificate::force_renewal {
  $certname = $::trusted['certname']
  $csr = $::agent_certificate_csr
  $path = $::agent_certificate_path
  unless $certname {
    fail "Got no trusted certificate name from the Puppet Agent (FQDN: '${::fqdn}')"
  }
  unless $csr {
    fail 'Certificate renewal requested, but got no CSR ("$::agent_certificate_cs")'
  }
  unless $path {
    fail 'Certificate renewal requested, but got no path to client certificate ("$::agent_certificate_path")'
  }
  $cert = ::agent_certificate::renew($certname, $csr)
  file { "${path}.old":
    source => $path,
  } -> file { $path:
    content => $cert,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
