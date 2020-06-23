# @summary
#   This simulates renewal. Should not be called directly
class agent_certificate::simulate_renewal {
  $certname = $::trusted['certname']
  $csr = $::agent_certificate_csr
  $path = $::agent_certificate_path
  if $certname {
    if $csr {
      ::agent_certificate::check_csr($certname, $csr)
      $former = "the former file would be moved to ${path}.old"
      notify { 'certifiate renewal: files on agent':
        message => "The signed certificate for ${certname} would be stored to ${path}, ${former}"
      }
    } else {
      notify { 'No CSR for renewal':
        message => 'Certificate renewal requested, but got no CSR ("$::puppet_pending_csr")',
      }
    }
  } else {
    notify { 'CSR but no certname':
      message => 'Rejecting CSR, got no trusted $::certname',
    }
  }
}
