Facter.add(:agent_certificate_csr) do
  confine agent_certificate_expires: true
  setcode do
    cert_name = Puppet.settings[:certname]
    key_file = "#{Puppet.settings[:privatekeydir]}/#{cert_name}.pem"
    # cert_file = "#{Puppet.settings[:certdir]}/#{cert_name}.pem"
    # certificate = OpenSSL::X509::Certificate.new(File.read(cert_file))
    private_key = OpenSSL::PKey::RSA.new(File.read(key_file))
    csr = OpenSSL::X509::Request.new
    csr.public_key = private_key.public_key
    csr.subject = OpenSSL::X509::Name.new([['CN', cert_name]])
    csr.version = 2
    # csr.add_attribute(extension_attribute(certificate.extensions))
    csr.sign(private_key, digest)
    csr.to_s
  end

  def extension_attribute(extensions)
    seq = OpenSSL::ASN1::Sequence(extensions)
    ext_req = OpenSSL::ASN1::Set([seq])
    OpenSSL::X509::Attribute.new('extReq', ext_req)
  end

  def digest
    if OpenSSL::Digest.const_defined?('SHA256')
      OpenSSL::Digest::SHA256.new
    elsif OpenSSL::Digest.const_defined?('SHA1')
      OpenSSL::Digest::SHA1.new
    elsif OpenSSL::Digest.const_defined?('SHA512')
      OpenSSL::Digest::SHA512.new
    elsif OpenSSL::Digest.const_defined?('SHA384')
      OpenSSL::Digest::SHA384.new
    elsif OpenSSL::Digest.const_defined?('SHA224')
      OpenSSL::Digest::SHA224.new
    else
      raise 'Error: No FIPS 140-2 compliant digest algorithm in OpenSSL::Digest'
    end
  end
end
