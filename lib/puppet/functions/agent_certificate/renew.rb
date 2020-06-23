Puppet::Functions.create_function(:'agent_certificate::renew') do
  # @param cert_name
  #   A string with your certificate name
  # @param csr
  #   CSR string
  # @param ttl
  #   Optional TTL in seconds
  dispatch :renew do
    param 'String', :cert_name
    param 'String', :csr
    optional_param 'Integer', :ttl
    return_type 'String'
  end

  # @param [String] name
  # @param [String] csr
  # @param [Number] ttl
  def renew(name, csr, ttl = nil)
    require File.expand_path('../../../util/agent_certificate/simple_ca', __FILE__)
    ca = Puppet::Util::AgentCertificate::SimpleCa.new(Puppet.settings)
    ca.with_info do |message|
      call_function('info', message)
    end
    ca.renew(name, OpenSSL::X509::Request.new(csr), ttl)
  end
end
