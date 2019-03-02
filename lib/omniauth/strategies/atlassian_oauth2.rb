# frozen_string_literal: true

require 'omniauth/strategies/oauth2'
require 'uri'

# Potential scopes: https://developer.atlassian.com/cloud/jira/platform/scopes/
# offline_access read:jira-user read:jira-work write:jira-work manage:jira-project manage:jira-configuration
#
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
             token_url: 'https://auth.atlassian.com/oauth/token',
             audience: 'api.atlassian.com'
      option :authorize_params,
             prompt: 'consent',
             audience: 'api.atlassian.com'

      uid do
        raw_info['myself']['accountId']
      end

      info do
        {
          name: raw_info['myself']['displayName'],
          email: raw_info['myself']['emailAddress'],
          nickname: raw_info['myself']['name'],
          location: raw_info['myself']['timeZone'],
          image: raw_info['myself']['avatarUrls']['48x48']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        return @raw_info if @raw_info

        # NOTE: api.atlassian.com, not auth.atlassian.com!
        accessible_resources_url = 'https://api.atlassian.com/oauth/token/accessible-resources'
        sites = JSON.parse(access_token.get(accessible_resources_url).body)

        # Jira's OAuth gives us many potential sites. To request information
        # about the user for the OmniAuth hash, pick the first one that has the
        # necessary 'read:jira-user' scope.
        jira_user_scope = 'read:jira-user'
        site = sites.find do |candidate_site|
          candidate_site['scopes'].include?(jira_user_scope)
        end
        unless site
          raise "No site found with scope #{jira_user_scope}, please ensure the scope ${jira_user_scope} is added to your OmniAuth config"
        end

        cloud_id = site['id']
        base_url = "https://api.atlassian.com/ex/jira/#{cloud_id}"
        myself_url = "#{base_url}/rest/api/3/myself"

        myself = JSON.parse(access_token.get(myself_url).body)

        @raw_info ||= {
          'site' => site,
          'sites' => sites,
          'myself' => myself
        }
      end
    end
  end
end
