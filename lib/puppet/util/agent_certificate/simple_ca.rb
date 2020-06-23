module Puppet::Util::AgentCertificate
  # Simplified CA API
  class SimpleCa
    # @param [Hash] settings Usually Puppet.settings
    def initialize(settings)
      require File.expand_path('./ca_settings', File.dirname(__FILE__))
      require File.expand_path('./ca_rest_api', File.dirname(__FILE__))
      @settings = CaSettings.new(settings)
      @api = CaRestApi.new(@settings)
      # Make sure we have a CA cert before starting
      @ca_cert = @settings.load_file(:localcacert) do |content|
        OpenSSL::X509::Certificate.new(content)
      end
    end

    # @param [OpenSSL::X509::Request] csr
    # @param [String] name
    # @return [String]
    # @param [Numeric] ttl
    def renew(name, csr, ttl = nil)
      assert_valid_csr(name, csr)
      info("Handling CSR renewal for subject '#{name}'")
      eventually_delete(name)
      send_certificate_request(name, csr)
      sign_certificate(name, signing_params(ttl))
      assert_valid_cert(fetch_certificate(name))
    end

    # @param [String] name
    # @param [OpenSSL::X509::Request] csr
    def assert_valid_csr(name, csr)
      unless csr.verify(csr.public_key)
        raise('CSR can not be verified')
      end
      unless csr.subject.to_s(OpenSSL::X509::Name::RFC2253) == "CN=#{name}"
        raise("CSR subject '#{csr.subject}' does not match expected certificate name 'CN=#{name}'")
      end

      return if csr.attributes.empty?
      raise("Unable to renew this certificate, CSR attributes comparision hasn't" \
        "been implemented yet: #{csr.attributes.inspect}")
    end

    def with_info(&block)
      @info = block
    end

    def eventually_delete(name)
      url = status_url(name)
      existing = @api.get(url)
      return if existing.is_a?(FalseClass)

      info("Certificate for #{name} exists, deleting: #{existing.inspect}")
      @api.delete(url)
    end

    def send_certificate_request(name, csr)
      info("Sending new CSR for #{name}")
      @api.put(csr_url(name), csr.to_s)
    end

    def signing_params(ttl)
      signing_params = {
        desired_state: 'signed',
      }
      unless ttl.nil?
        signing_params[:cert_ttl] = ttl
      end
      signing_params
    end

    def sign_certificate(name, params)
      info("Signing CSR for #{name}")
      signed = @api.put(status_url(name), params)
      return if signed
      raise "Failed to sign CSR for #{name}"
    end

    # @param [String] name
    # @return [String]
    def fetch_certificate(name)
      @api.get(certificate_url(name)) || raise("Could not fetch certificate for #{name}")
    end

    # @param [String] new_cert
    # @return [String]
    def assert_valid_cert(new_cert)
      ca = @ca_cert
      # cert = OpenSSL::X509::Certificate.new('FAKE-ERROR' + new_cert)
      cert = OpenSSL::X509::Certificate.new(new_cert)
      unless cert.issuer.to_s == ca.subject.to_s
        raise("New certificate has been signed by #{cert.issuer}, not by #{ca.subject}")
      end

      raise('Verifying the new certificate failed') unless cert.verify(ca.public_key)
      new_cert
    end

    # @param [String] name
    # @return [String]
    def certificate_url(name)
      api_url('certificate', name)
    end

    # @param [String] name
    # @return [String]
    def csr_url(name)
      api_url('certificate_request', name)
    end

    # @param [String] name
    # @return [String]
    def status_url(name)
      api_url('certificate_status', name)
    end

    # @param [String] url
    # @param [String] cert_name
    # @return [String]
    def api_url(url, cert_name)
      "/#{url}/#{cert_name}?environment=any"
    end

    # @param [String] message
    def info(message)
      return unless @info
      @info.call(message)
    end

    # @param [OpenSSL::X509::Certificate] certificate
    # @return [Array]
    def get_alt_names(certificate)
      names = []
      certificate.extensions.each do |extension|
        next unless extension.oid == 'subjectAltName'
        extension.value.split(',').each do |_, value|
          value.strip!
          if value.start_with?('DNS:')
            names.push(value)
          end
        end
      end
      names
    end
  end
end
