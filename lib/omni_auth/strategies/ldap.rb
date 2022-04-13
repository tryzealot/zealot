# frozen_string_literal: true
#
# Modify to work under in omniauth 2
# Original repository: https://gitlab.com/gitlab-org/omniauth-ldap
require 'omniauth'

module OmniAuth
  module Strategies
    class Ldap
      include OmniAuth::Strategy

      InvalidCredentialsError = Class.new(StandardError)

      @@config = {
        'name' => 'cn',
        'first_name' => 'givenName',
        'last_name' => 'sn',
        'email' => ['mail', "email", 'userPrincipalName'],
        'phone' => ['telephoneNumber', 'homePhone', 'facsimileTelephoneNumber'],
        'mobile' => ['mobile', 'mobileTelephoneNumber'],
        'nickname' => ['uid', 'userid', 'sAMAccountName'],
        'title' => 'title',
        'location' => {"%0, %1, %2, %3 %4" => [['address', 'postalAddress', 'homePostalAddress', 'street', 'streetAddress'], ['l'], ['st'],['co'],['postOfficeBox']]},
        'uid' => 'dn',
        'url' => ['wwwhomepage'],
        'image' => 'jpegPhoto',
        'description' => 'description'
      }

      option :name, 'ldap'
      option :title, "LDAP Authentication" #default title for authentication form
      option :port, 389
      option :method, :plain
      option :disable_verify_certificates, false
      option :ca_file, nil
      option :ssl_version, nil # use OpenSSL default if nil
      option :uid, 'sAMAccountName'
      option :name_proc, lambda {|n| n}

      def request_phase
        OmniAuth::Strategies::Ldap::Adaptor.validate @options
        f = OmniAuth::Form.new(:title => (options[:title] || "LDAP Authentication"), :url => callback_path)
        f.text_field 'Login', 'username'
        f.password_field 'Password', 'password'
        f.button "Sign In"
        f.to_response
      end

      def callback_phase
        @adaptor = OmniAuth::Strategies::Ldap::Adaptor.new @options

        return fail!(:invalid_request_method) unless valid_request_method?
        return fail!(:missing_credentials) if missing_credentials?
        begin
          @ldap_user_info = @adaptor.bind_as(:filter => filter(@adaptor), :size => 1, :password => request['password'])

          unless @ldap_user_info
            return fail!(:invalid_credentials, InvalidCredentialsError.new("Invalid credentials for #{request['username']}"))
          end

          @user_info = self.class.map_user(@@config, @ldap_user_info)
          super
        rescue Exception => e
          return fail!(:ldap_error, e)
        end
      end

      def filter(adaptor)
        if adaptor.filter and !adaptor.filter.empty?
          username = Net::LDAP::Filter.escape(@options[:name_proc].call(request['username']))
          Net::LDAP::Filter.construct(adaptor.filter % { username: username })
        else
          Net::LDAP::Filter.equals(adaptor.uid, @options[:name_proc].call(request['username']))
        end
      end

      uid {
        @user_info["uid"]
      }
      info {
        @user_info
      }
      extra {
        { :raw_info => @ldap_user_info }
      }

      def self.map_user(mapper, object)
        user = {}
        mapper.each do |key, value|
          case value
          when String
            user[key] = object[value.downcase.to_sym].first if object.respond_to? value.downcase.to_sym
          when Array
            value.each {|v| (user[key] = object[v.downcase.to_sym].first; break;) if object.respond_to? v.downcase.to_sym}
          when Hash
            value.map do |key1, value1|
              pattern = key1.dup
              value1.each_with_index do |v,i|
                part = ''; v.collect(&:downcase).collect(&:to_sym).each {|v1| (part = object[v1].first; break;) if object.respond_to? v1}
                pattern.gsub!("%#{i}",part||'')
              end
              user[key] = pattern
            end
          end
        end
        user
      end

      protected

      def valid_request_method?
        request.env['REQUEST_METHOD'] == 'POST'
      end

      def missing_credentials?
        request['username'].nil? or request['username'].empty? or request['password'].nil? or request['password'].empty?
      end # missing_credentials?
    end
  end
end
