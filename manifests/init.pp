# @summary
#   This Module allows to auto-renew Puppetagent-Certificates
#
# This Class should be included by agent_certificate::auto_renew
# It will fail in the unlikely Situation, where the trusted Fact $::trusted['certname'] is not present
#
# @param expiration
#   Time in Seconds, after which a renewed Certificate will expire
# @param dry_mode
#   if the Renewal is simulated only, or real
#
# @example with Defaults from Hiera
#   include agent_certificate::auto_renew
class agent_certificate(
  Integer $expiration,
  Boolean $dry_mode,
) {
  assert_private()

  unless $::trusted['certname'] {
    # this should never happen, as the trusted Fact always gets set by Puppetmaster
    fail "${::facts['fqdn']}: Got no trusted certificate for this FQDN from the Puppet Agent"
  }
}
