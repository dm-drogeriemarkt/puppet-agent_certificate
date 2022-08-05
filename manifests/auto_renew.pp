# @summary
#   This Module allows to auto-renew Puppetagent-Certificates
#   This Class decides, if Renewal is forced or simulated
#
# @param expiration
#   Time in Seconds, after which a renewed Certificate will expire
# @param dry_mode
#   if the Renewal is simulated only, or real
#
# @example with Defaults from Hiera
#   include agent_certificate::auto_renew
# @example with overwrites to enable wet mode
#   class { 'agent_certificate::auto_renew':
#     dry_mode => false,
#   }
class agent_certificate::auto_renew (
  Integer $expiration,
  Boolean $dry_mode,
) {
  if $::facts['agent_certificate_expires'] {
    unless $::trusted['certname'] {
      # this should never happen, as the trusted Fact always gets set by Puppetmaster
      fail "${::facts['fqdn']}: Got no trusted certificate for this FQDN from the Puppet Agent"
    }

    if $::facts['clientnoop'] or $dry_mode {
      contain agent_certificate::simulate_renewal
    } else {
      contain agent_certificate::force_renewal
    }
  }
}
