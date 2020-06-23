# agent_certificate Puppet Module

This module allows to auto-renew Puppet Agent certificates

#### Table of Contents

1. [Description](#description)
1. [Workflow](#workflow)
3. [Security](#security)
3. [Usage](#usage)
4. [Limitations](#limitations)

## Description

Ever struggled with the renewal of your Puppet Agent certificates? Then this
module might be what you're looking for. It has been designed to renew your
certificates in an automated way.

## Workflow

This module ships three additional facts:

* **agent_certificate_csr**: a new CSR for the very same certificate name and
  private key. Shipped only when `agent_certificate_expires` is `true`
* **agent_certificate_expires**: whether the current certificate reached 85% of
  it's lifetime
* **agent_certificate_path**: Agent `hostcert` setting

During catalog compilation, a pending CSR will be validated. If accepted (read
the [Security](#security) section for details), the following steps take place
on your compile master during (one single) catalog compile time:

* in case the CA knows about the former certificate, it will be deleted (NOT
  revoked)
* the new CSR will be sent to the CA
* your CA server will be told to sign the new CSR
* the new Certificate will be fetched
* the Puppet catalog will contain file definitions backing up your old and
  creating the new certificate file on your Agent

The next Puppet Run should then take place with the renewed certificate.

## Security

We cannot trust facts, so the following checks are applied at server side:

* No CSRs are signed for Puppet runs without a **trusted** certificate (read:
  `$::trusted['certname']`).
* CSRs that haven't been signed are rejected
* CSRs with a subject not matching the nodes former certificate name are rejected
* CSRs with subject alternative names are rejected in case the former certificate
  doesn't show the very same alternative names
* ~~Other CSR extensions are only allowed if the match the one in the former certificate~~
  (not yet, currently we reject requests with extensions)

Above checks involving the former certificate will result in the request being rejected
in case the CA doesn't know the former certificate. CSRs with no subjectAlternativeName
and no extension are processed even if the former certificate has been removed (but not
revoked) on your CA server.

## Usage

Usually all you have to do is to somehow assign this class:

```puppet
include agent_certificate::auto_renew
```

### Setting a custom TTL

You might want to tune the TTL, as automatic renewal allows for shorter TTLs:

```puppet
class { 'agent_certificate::auto_renew':
  # TTL for renewed certificates
  # - MUST be Integer (seconds)
  # - defaults to the ca_ttl setting if not given
  # - this default is 86400 * 365 * 5 = 157680000
  # - example shows 90 days:
  expiration => 86400 * 90,
}
```

Advantage: you can keep your revocation lists smaller. We'd recommend to change
the `ca_ttl` setting instead of using this feature. However, this parameter
allows to have different TTLs for different types of host. No need to pollute
your CRL (Certificate Revocation List) with lots of entries for short-lived
containers or virtual machines.

### Running in Dry Mode

**Dry Mode** allows to run simulation. Log will show notices telling you what
WOULD happen when running in wet mode:

```puppet
class { 'agent_certificate::auto_renew':
  dry_mode => true,
}
```

### No Operation Mode

Don't let **dry mode** scare you, it is not a requirement for noop/test runs.
This module also supports `--noop`. The challenge was that Facter doesn't care
about `--noop` (there is no reason it should), and server-side Puppet functions
are triggered run in `noop` mode too. So as experiences Puppet users might
expect, this could have undesired side-effects if we wouldn't care.

Be assured, `--noop` "just works" as expected.


## Limitations

* **Agent Certificates only**: this module replaces Agent Certificates, it
  doesn't care about expiring CA certificates
* **No support for Certificate Extenstions**: Certificate extensions (like
  `pp_*`) are currently ignored, but we're working on this
