# @summary
#   This module allows to auto-renew Puppet Agent certificates
class agent_certificate::auto_renew (
  Optional[Integer] $expiration = undef,
  Boolean $dry_mode = false
){
  if $::agent_certificate_expires {
    if $::clientnoop or $dry_mode {
      include agent_certificate::simulate_renewal
    } else {
      include agent_certificate::force_renewal
    }
  }
}
