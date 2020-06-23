Puppet::Functions.create_function(:'agent_certificate::check_csr') do
  # @param cert_name
  #   A string with your certificate name
  # @param csr
  #   CSR string
  dispatch :check_csr do
    param 'String', :cert_name
    param 'String', :csr
  end

  # @param [String] name
  # @param [String] csr
  def check_csr(name, csr)
    require File.expand_path('../../../util/agent_certificate/simple_ca', __FILE__)
    ca = Puppet::Util::SimpleCa.new(Puppet.settings)

    ca.with_info do |message|
      call_function('info', message)
    end
    ca.assert_valid_csr(name, OpenSSL::X509::Request.new(csr))
    call_function('create_resources', 'notify', {
        'CSR is valid': {
            message: "CSR submitted for #{name} would be accepted valid"
      }
    })
  end
end
