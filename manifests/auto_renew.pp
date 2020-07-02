# @summary
#   This Class decides, if Renewal is forced or simulated
#
# for more Info and Examples see init.pp
class agent_certificate::auto_renew() {
  if $::facts['agent_certificate_expires'] {
    contain agent_certificate

    if $::facts['clientnoop'] or $::agent_certificate::dry_mode {
      contain agent_certificate::simulate_renewal
    } else {
      contain agent_certificate::force_renewal
    }
  }
}
