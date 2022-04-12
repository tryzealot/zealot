# frozen_string_literal: true
#
# Modify to work under in omniauth 2
# Original repository: https://gitlab.com/gitlab-org/omniauth-ldap
require 'rack'
require 'net/ldap'
require 'net/ntlm'
require 'sasl'
require 'kconv'

module OmniAuth
  module LDAP
    class Adaptor
      class LdapError < StandardError; end
      class ConfigurationError < StandardError; end
      class AuthenticationError < StandardError; end
      class ConnectionError < StandardError; end

      VALID_ADAPTER_CONFIGURATION_KEYS = [
        :hosts, :host, :port, :encryption, :disable_verify_certificates, :bind_dn, :password, :try_sasl,
        :sasl_mechanisms, :uid, :base, :allow_anonymous, :filter, :tls_options,

        # Deprecated
        :method,
        :ca_file,
        :ssl_version
      ]

      # A list of needed keys. Possible alternatives are specified using sub-lists.
      MUST_HAVE_KEYS = [
        :base,
        [:encryption, :method], # :method is deprecated
        [:hosts, :host],
        [:hosts, :port],
        [:uid, :filter]
      ]

      ENCRYPTION_METHOD = {
        :simple_tls => :simple_tls,
        :start_tls => :start_tls,
        :plain => nil,

        # Deprecated. This mapping aimed to be user-friendly, but only caused
        # confusion. Better to pass-through the actual `Net::LDAP` encryption type.
        :ssl => :simple_tls,
        :tls => :start_tls,
      }

      attr_accessor :bind_dn, :password
      attr_reader :connection, :uid, :base, :auth, :filter

      def self.validate(configuration={})
        message = []
        MUST_HAVE_KEYS.each do |names|
          names = [names].flatten
          missing_keys = names.select{|name| configuration[name].nil?}
          if missing_keys == names
            message << names.join(' or ')
          end
        end
        raise ArgumentError.new(message.join(",") +" MUST be provided") unless message.empty?
      end

      def initialize(configuration={})
        Adaptor.validate(configuration)
        @configuration = configuration.dup
        @configuration[:allow_anonymous] ||= false
        @logger = @configuration.delete(:logger)
        VALID_ADAPTER_CONFIGURATION_KEYS.each do |name|
          instance_variable_set("@#{name}", @configuration[name])
        end
        config = {
          base: @base,
          hosts: @hosts,
          host: @host,
          port: @port,
          encryption: encryption_options
        }
        @bind_method = @try_sasl ? :sasl : (@allow_anonymous||!@bind_dn||!@password ? :anonymous : :simple)


        @auth = sasl_auths({:username => @bind_dn, :password => @password}).first if @bind_method == :sasl
        @auth ||= { :method => @bind_method,
                    :username => @bind_dn,
                    :password => @password
                  }
        config[:auth] = @auth
        @connection = Net::LDAP.new(config)
      end

      #:base => "dc=yourcompany, dc=com",
      # :filter => "(mail=#{user})",
      # :password => psw
      def bind_as(args = {})
        result = false
        @connection.open do |me|
          rs = me.search args
          if rs and rs.first and dn = rs.first.dn
            password = args[:password]
            method = args[:method] || @method
            password = password.call if password.respond_to?(:call)
            if method == 'sasl'
            result = rs.first if me.bind(sasl_auths({:username => dn, :password => password}).first)
            else
            result = rs.first if me.bind(:method => :simple, :username => dn,
                                :password => password)
            end
          end
        end
        result
      end

      private

      def encryption_options
        translated_method = translate_method
        return nil unless translated_method

        {
          method: translated_method,
          tls_options: tls_options(translated_method)
        }
      end

      def translate_method
        method = @encryption || @method
        method ||= "plain"
        normalized_method = method.to_s.downcase.to_sym

        unless ENCRYPTION_METHOD.has_key?(normalized_method)
          available_methods = ENCRYPTION_METHOD.keys.collect {|m| m.inspect}.join(", ")
          format = "%s is not one of the available connect methods: %s"
          raise ConfigurationError, format % [method.inspect, available_methods]
        end

        ENCRYPTION_METHOD[normalized_method]
      end

      def tls_options(translated_method)
        return {} if translated_method == nil # (plain)

        options = default_options

        if @tls_options
          # Prevent blank config values from overwriting SSL defaults
          configured_options = sanitize_hash_values(@tls_options)
          configured_options = symbolize_hash_keys(configured_options)

          options.merge!(configured_options)
        end

        # Retain backward compatibility until deprecated configs are removed.
        options[:ca_file] = @ca_file if @ca_file
        options[:ssl_version] = @ssl_version if @ssl_version

        options
      end

      def sasl_auths(options={})
        auths = []
        sasl_mechanisms = options[:sasl_mechanisms] || @sasl_mechanisms
        sasl_mechanisms.each do |mechanism|
          normalized_mechanism = mechanism.downcase.gsub(/-/, '_')
          sasl_bind_setup = "sasl_bind_setup_#{normalized_mechanism}"
          next unless respond_to?(sasl_bind_setup, true)
          initial_credential, challenge_response = send(sasl_bind_setup, options)
          auths << {
            :method => :sasl,
            :initial_credential => initial_credential,
            :mechanism => mechanism,
            :challenge_response => challenge_response
          }
        end
        auths
      end

      def sasl_bind_setup_digest_md5(options)
        bind_dn = options[:username]
        initial_credential = ""
        challenge_response = Proc.new do |cred|
          pref = SASL::Preferences.new :digest_uri => "ldap/#{@host}", :username => bind_dn, :has_password? => true, :password => options[:password]
          sasl = SASL.new("DIGEST-MD5", pref)
          response = sasl.receive("challenge", cred)
          response[1]
        end
        [initial_credential, challenge_response]
      end

      def sasl_bind_setup_gss_spnego(options)
        bind_dn = options[:username]
        psw = options[:password]
        raise LdapError.new( "invalid binding information" ) unless (bind_dn && psw)

        nego = proc {|challenge|
          t2_msg = Net::NTLM::Message.parse( challenge )
          bind_dn, domain = bind_dn.split('\\').reverse
          t2_msg.target_name = Net::NTLM::encode_utf16le(domain) if domain
          t3_msg = t2_msg.response( {:user => bind_dn, :password => psw}, {:ntlmv2 => true} )
          t3_msg.serialize
        }
        [Net::NTLM::Message::Type1.new.serialize, nego]
      end

      private

      def default_options
        if @disable_verify_certificates
          # It is important to explicitly set verify_mode for two reasons:
          # 1. The behavior of OpenSSL is undefined when verify_mode is not set.
          # 2. The net-ldap gem implementation verifies the certificate hostname
          #    unless verify_mode is set to VERIFY_NONE.
          { verify_mode: OpenSSL::SSL::VERIFY_NONE }
        else
          OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.dup
        end
      end

      # Removes keys that have blank values
      #
      # This gem may not always be in the context of Rails so we
      # do this rather than `.blank?`.
      def sanitize_hash_values(hash)
        hash.delete_if do |_, value|
          value.nil? ||
          (value.is_a?(String) && value !~ /\S/)
        end
      end

      def symbolize_hash_keys(hash)
        hash.keys.each do |key|
          hash[key.to_sym] = hash[key]
        end

        hash
      end
    end
  end
end
