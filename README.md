[![Gem Version](https://badge.fury.io/rb/omniauth-atlassian-oauth2.svg)](https://badge.fury.io/rb/omniauth-atlassian-oauth2)

# OmniAuth Atlassian OAuth2 Strategy

Strategy to authenticate with Atlassian via OAuth2 in OmniAuth.

Get your API key at: https://developer.atlassian.com/apps/ Note the Client ID
and the Client Secret.

For more details, read the Atlassian docs about OAuth 2.0 (3LO):
https://developer.atlassian.com/cloud/jira/platform/oauth-2-authorization-code-grants-3lo-for-apps/

Note that as of March 2019, the OAuth 2.0 APIs at in "developer preview" mode
with Atlassian. See
[ACJIRA-1588](https://ecosystem.atlassian.net/browse/ACJIRA-1588) for updates.

## Installation

Add to your `Gemfile`:

```ruby
gem 'omniauth-atlassian-oauth2'
```

Then `bundle install`.

## Atlassian API Setup

* Go to 'https://developer.atlassian.com/apps/'
* Create a new app.
* Note the Client ID and Secret values in the App Details section.
* Under APIs and Features, add the "Authorization code grants" feature.
  Configure the feature with your callback URL (something like
  http://localhost:3000/auth/atlassian_oauth2/callback).
* Under APIs and Features, add the "Jira platform REST API" API. Configure the
  API by adding the "View Jira issue data" and "View user profiles" scopes. These coincide with the scopes listed in the [Jira scopes](https://developer.atlassian.com/cloud/jira/platform/oauth-2-authorization-code-grants-3lo-for-apps/) section of the Atlassian Docs. Add additional scopes in this UI as needed.

## Usage

Here's an example for adding the middleware to a Rails app in
`config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :atlassian_oauth2, ENV['ATLASSIAN_CLIENT_ID'], ENV['ATLASSIAN_CLIENT_SECRET']
    scope: "offline_access read:jira-user read:jira-work",
    prompt: "consent",
end
```

This OmniAuth strategy makes API calls that require the `read:jira-user` scope,
so that scope must be included by you in your OmniAuth configuration. The
`offline_access` scope must be included if you wish to attain a refresh token.
You may wish to include additional scopes depending on how you've configured
your app in the Atlassian UI.

You can now access the OmniAuth Atlassian OAuth2 URL: `/auth/atlassian_oauth2`

NOTE: While developing your application, if you change the scope in the
initializer you will need to restart your app server. Remember that either the
'email' or 'profile' scope is required!

## Auth Hash

Here's an example of an authentication hash available in the callback by
accessing `request.env['omniauth.auth']`:

Note: Atlassian's OAuth2 flow grants access to potentially many Atlassian
"sites", and each site defines a user on its own. There's no single definitive
profile of the user. We must loop through the sites and call the
`/rest/api/3/myself` endpoint for each. `auth_hash['extra']['raw_info']['site']`
is the site that was used to populate `auth_hash['info']` and
`auth_hash['uid']`. `auth_hash['extra']['raw_info']['sites']` is the data for
all the sites available for the user.

After authing a user, when you make API calls over time, you should follow the
[Atlassian OAuth 2.0 docs](https://developer.atlassian.com/cloud/jira/platform/oauth-2-authorization-code-grants-3lo-for-apps/)
and continue to check the `accessible-resources` endpoint to ensure your app
continues to have access to the sites you expect.

```ruby
{
  "provider" => "google_oauth2",
  "uid" => "100000000000000000000",
  "info" => {
    "name" => "John Smith",
    "email" => "john@example.com",
    "nickname" => "john_smith", # username
    "location" => "Australia/Sydney", # time zone
    "image" => "https://whatever.atlassiancdn.com/photo_48x48.jpg", # 48x48 pixels
  },
  "credentials" => {
    "token" => "TOKEN",
    "refresh_token" => "REFRESH_TOKEN",
    "expires_at" => 1496120719,
    "expires" => true
  },
  "extra" => {
    "raw_info" => {
      "site" => {},
      "sites" => {},
      "myself" => {},
    }
  }
}
```

## License

Copyright (c) 2019 by Ben Standefer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
