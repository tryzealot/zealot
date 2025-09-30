# frozen_string_literal: true

# Copyright (c) 2011 Michael Bleigh and Intridea, Inc.
# Copyright (c) 2021 TechKnowLogick
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# Repository: https://github.com/techknowlogick/omniauth-gitea

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Gitea < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => 'https://gitea.com',
        :authorize_url => 'https://gitea.com/login/oauth/authorize',
        :token_url => 'https://gitea.com/login/oauth/access_token'
      }

      def request_phase
        super
      end

      def authorize_params
        super.tap do |params|
          %w[scope client_options].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end
        end
      end

      uid { raw_info['id'].to_s }

      info do
        {
          'nickname' => raw_info['login'],
          'email' => raw_info['email'],
          'name' => raw_info['full_name'],
          'image' => raw_info['avatar_url'],
          'description' => raw_info['description'],
          'website' => raw_info['website'],
          'location' => raw_info['location'],
        }
      end

      extra do
        {:raw_info => raw_info }
      end

      def raw_info
        access_token.options[:mode] = :header
        @raw_info ||= access_token.get('api/v1/user').parsed
      end

      def callback_url
        full_host + callback_path
      end
    end
  end
end
