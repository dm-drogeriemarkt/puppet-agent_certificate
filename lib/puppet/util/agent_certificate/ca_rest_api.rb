module Puppet::Util::AgentCertificate
  # Simplified REST API
  class CaRestApi
    USER_AGENT = 'PuppetCertRenewal'.freeze

    # @param [Puppet::Util::AgentCertificate::CaSettings] settings
    def initialize(settings)
      @cert = settings.load_file(:hostcert) do |content|
        OpenSSL::X509::Certificate.new(content)
      end
      @key = settings.load_file(:hostprivkey) do |content|
        OpenSSL::PKey.read(content)
      end
      @ca_file = settings[:localcacert]
      @base_url = "https://#{settings[:ca_server]}:#{settings[:ca_port]}/puppet-ca/v1"
    end

    # @param [String] url
    # @return [String, FalseClass]
    def get(url)
      request(prepare_get(url))
    end

    # @param [String] url
    # @return [String, FalseClass]
    def get_plain(url)
      request(prepare_get(url, 'text/plain'))
    end

    # @param [String] url
    # @return [String, FalseClass]
    def delete(url)
      req = Net::HTTP::Delete.new(uri(url))
      req['user-agent'] = USER_AGENT
      request(req)
    end

    # @param [String] url
    # @return [String, FalseClass]
    def put(url, body)
      req = prepare_put(url, body)
      request(req)
    end

    # @param [String] url
    # @return [Module<URI>]
    def uri(url)
      URI(@base_url + url)
    end

    def prepare_get(url, accept = 'application/json')
      req = Net::HTTP::Get.new(uri(url))
      req['user-agent'] = USER_AGENT
      req['Accept'] = accept
      req
    end

    def prepare_put(url, body)
      req = Net::HTTP::Put.new(uri(url))
      req['user-agent'] = USER_AGENT
      if body.is_a?(String)
        req['accept'] = 'text/plain'
        req['content-type'] = 'text/plain'
        req.body = body
      else
        req['accept'] = 'application/json'
        req['content-type'] = 'application/json'
        req.body = body.to_json
      end
      req
    end

    # @param [Net::HTTPRequest] req
    # @return [String, FalseClass]
    def request(req)
      uri = uri(@base_url)
      Net::HTTP.start(
        uri.hostname,
        uri.port,
        use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        cert: @cert,
        key: @key,
        ca_file: @ca_file,
      ) do |http|
        handle_response(http.request(req), req)
      end
    end

    # @param [Net::HTTPResponse] response
    # @param [Net::HTTPRequest] req
    # @return [String, FalseClass]
    def handle_response(response, req)
      if response.is_a?(Net::HTTPNotFound)
        return false
      end

      unless response.is_a?(Net::HTTPSuccess)
        raise "Request failed: #{response} for #{req.method} #{req.uri}"
      end

      parse_response(response)
    end

    # Try JSON, fall back to plaintext
    # @param [Net::HTTPResponse] response
    # @return [String]
    def parse_response(response)
      if response['content-type'].to_s =~ %r{json}
        JSON.parse(response.body)
      else
        response.body.to_s
      end
    end

    # @param [String] path
    # @param [String] setting
    # @return [String]
    def load_settings_file(path, setting)
      raise 'No block given' unless block_given?
      yield(File.read(path))
    rescue Errno::ENOENT
      raise "Could not load '#{setting}' from '#{path}'"
    rescue OpenSSL::OpenSSLError => e
      raise "Could not parse '#{setting}' at '#{path}: #{e.message}"
    end
  end
end
