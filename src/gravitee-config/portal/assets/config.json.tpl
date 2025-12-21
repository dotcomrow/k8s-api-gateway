{
  "baseURL": "https://gravitee.teleport.app.suncoast.systems/portal/environments/DEFAULT/",
  "portal": {
    "baseURL": "https://gravitee.teleport.app.suncoast.systems"
  },
  "loaderURL": "assets/images/gravitee-loader.gif",
  "authentication": {
    "forceLogin": false,
    "localLogin": {
      "enabled": true
    },
    "oauth2": {
      "enabled": true,
      "clientId": "${PORTAL_OAUTH_CLIENT_ID}",
      "authorizationEndpoint": "${PORTAL_SSO_AUTHORIZE_URL}",
      "tokenEndpoint": "${PORTAL_SSO_TOKEN_URL}",
      "userInfoEndpoint": "${PORTAL_SSO_USERINFO_URL}",
      "name": "${PORTAL_SSO_PROVIDER_NAME}",
      "description": "${PORTAL_SSO_PROVIDER_DESCRIPTION}",
      "buttonText": "${PORTAL_SSO_BUTTON_TEXT}",
      "scope": [
        "read:user",
        "read:org"
      ]
    }
  },
  "pagination": {
    "size": {
      "default": 10,
      "values": [5, 10, 25, 50, 100]
    }
  }
}
