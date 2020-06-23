module Puppet::Util::AgentCertificate
  # Simplified REST API
  class CaSettings
    # @param [Hash] settings
    def initialize(settings)
      @settings = settings
    end

    # @param [String, Symbol] key
    # @param [String, NilClass] default
    def get(key, default = nil)
      @settings[key] || default
    end

    # @param [String, Symbol] key
    # @return [String]
    def get_required(key)
      @settings[key] || raise("Got not #{key} setting")
    end

    def [](key)
      get_required(key)
    end

    # @param [String, Symbol] key
    # @return [String]
    def load_file(key)
      raise 'No block given' unless block_given?
      path = get_required(key)
      begin
        yield(File.read(path))
      rescue Errno::ENOENT
        raise "Could not load '#{key}' file from '#{path}'"
      rescue OpenSSL::OpenSSLError => e
        raise "Could not parse '#{key}' file loaded from '#{path}': #{e.message}"
      end
    end
  end
end
