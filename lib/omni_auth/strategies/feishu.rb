# frozen_string_literal: true
#
# Modify to work under in omniauth 2
# Original repository: https://github.com/renny-ren/omniauth-feishu
#
# TODO: Remove file after bump new release 0.1.7 or 0.2.0?
require 'omniauth-oauth2'

module OmniAuth
  module Strategies

    # 飞书登录
    #
    # 飞书要求请求采用 json 格式主体，很多都需要自定义
    # 官方文档： https://open.feishu.cn/document/ukTMukTMukTM/uETOwYjLxkDM24SM5AjN
    class Feishu < OmniAuth::Strategies::OAuth2
      class NoAppAccessTokenError < StandardError; end

      option :name, 'feishu'

      option :client_options, {
        site: 'https://open.feishu.cn/open-apis/authen/v1/',
        authorize_url: 'user_auth_page_beta',
        token_url: 'access_token',
        app_access_token_url: 'https://open.feishu.cn/open-apis/auth/v3/app_access_token/internal',
        user_info_url: 'user_info'
      }

      uid { raw_info['user_id'] }

      info do
        {
          name: raw_info['name'],
          email: raw_info['email'],
          mobile: raw_info['mobile'],
          avatar_url: raw_info['avatar_url'],
          avatar_thumb: raw_info['avatar_thumb'],
          avatar_middle: raw_info['avatar_middle'],
          avatar_big: raw_info['avatar_big'],
          user_id: raw_info['user_id'],
          union_id: raw_info['union_id'],
          open_id: raw_info['open_id'],
          en_name: raw_info['en_name']
        }
      end

      def raw_info
        @raw_info ||= client.request(:get, options.client_options.user_info_url,
                                      { headers: {
                                          'Content-Type' => 'application/json; charset=utf-8',
                                          'Authorization' => "Bearer #{access_token.token}"
                                        }
                                      })
                            .parsed['data']
      end

      def authorize_params
        super.tap do |params|
          params[:app_id] = options.client_id
        end
      end

      # 飞书采用非标准 OAuth 2 请求体和返回结构体，需要自定义
      def build_access_token
        code = request.params['code']
        data = client.request(:post, options.client_options.token_url,
                              { body: {
                                  code: code,
                                  grant_type: 'authorization_code'
                                }.to_json,
                                headers: {
                                  'Content-Type' => 'application/json; charset=utf-8',
                                  'Authorization' => "Bearer #{app_access_token}"
                                }
                              })
                      .parsed['data']

        ::OAuth2::AccessToken.from_hash(client, data)
      end

      private

      def app_access_token
        return @app_access_token if @app_access_token

        @app_access_token ||= client.request(:post, options.client_options.app_access_token_url,
                                              { body: {
                                                  app_id: options.client_id,
                                                  app_secret: options.client_secret
                                                }.to_json,
                                                headers: {
                                                  'Content-Type' => 'application/json; charset=utf-8'
                                                }
                                              })
                                    .parsed['app_access_token']

        raise NoAppAccessTokenError, 'No app access token' unless @app_access_token

        @app_access_token
      end
    end
  end
end
