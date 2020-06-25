# @summary
#   This simulates renewal. Should be called from agent_certificate::auto_renew
class agent_certificate::simulate_renewal {
  assert_private()

  if $::facts['agent_certificate_csr'] {
    ::agent_certificate::check_csr($::trusted['certname'], $::facts['agent_certificate_csr'])
    $former = "the former file would be moved to ${::facts['agent_certificate_path']}.old"
    notify { 'certifiate renewal: files on agent':
      message => "The signed certificate for ${::trusted['certname']} would be stored to ${::facts['agent_certificate_path']}, ${former}"
    }
  } else {
    notify { 'No CSR for renewal':
      message => 'Certificate renewal requested, but got no CSR (Fact agent_certificate_csr is empty)',
    }
  }
}
