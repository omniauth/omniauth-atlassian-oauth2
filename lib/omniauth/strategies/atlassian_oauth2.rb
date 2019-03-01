# frozen_string_literal: true

require 'omniauth/strategies/oauth2'
require 'uri'

# NOTE: %3A in scope is a colon
#
# https://auth.atlassian.com/authorize?
# audience=api.atlassian.com
# client_id=7v6ghRsOM5BIHj4jmCxEmxyL743hwTEq
# scope=read%3Ajira-user
# redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fauth%2Fatlassian%2Fcallback
# state=${YOUR_USER_BOUND_VALUE}
# response_type=code
# prompt=consent

# Scopes: https://developer.atlassian.com/cloud/jira/platform/scopes/
# read:jira-user
# read:jira-work
# write:jira-work
# manage:jira-project
# manage:jira-configuration
# Separate scopes with a space (%20)
# https://developer.atlassian.com/cloud/jira/platform/oauth-2-authorization-code-grants-3lo-for-apps/

module OmniAuth
  module Strategies
    # Omniauth strategy for Atlassian
    class AtlassianOauth2 < OmniAuth::Strategies::OAuth2
      option :name, 'atlassian_oauth2'
      option :client_options,
             site: 'https://auth.atlassian.com',
             authorize_url: 'https://auth.atlassian.com/authorize',
             token_url: 'https://auth.atlassian.com/oauth2/token',
             audience: 'api.atlassian.com'
      option :authorize_params,
             prompt: 'consent',
             audience: 'api.atlassian.com'

      def request_phase
        url = client.auth_code.authorize_url({:redirect_uri => callback_url}.merge(authorize_params))
        puts "redirecting to"
        puts url
        redirect url
      end

      uid { raw_info['sub'] }

      info do
        {
          name: raw_info['name']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= JSON.parse(access_token.get('/rest/api/3/myself')).body
      end
    end
  end
end
