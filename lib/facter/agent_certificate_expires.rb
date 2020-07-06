Facter.add(:agent_certificate_expires) do
  setcode do
    certname = Puppet.settings[:certname]
    cert_file = "#{Puppet.settings[:certdir]}/#{certname}.pem"
    if File.exist?(cert_file)
      cert = Puppet::SSL::Certificate.indirection.find(certname)
      expires_soon?(cert.content)
    else
      false
    end
  end

  # @param [OpenSSL::X509::Certificate] cert
  # @param [Integer] percent
  def expires_soon?(cert, percent = 15)
    time_left = cert.not_after - Time.now
    time_total = cert.not_after - cert.not_before
    time_left / time_total < (percent / 100.0)
  end
end
