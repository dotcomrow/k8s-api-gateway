{
  "baseURL": "https://gravitee.teleport.app.suncoast.systems/portal/environments/DEFAULT/",
  "portal": {
    "baseURL": "https://gravitee.teleport.app.suncoast.systems"
  },
  "loaderURL": "assets/images/gravitee-loader.gif",
  "authentication": {
    "forceLogin": true,
    "localLogin": {
      "enabled": false
    },
    "providers": [
      {
        "id": "github",
        "type": "oauth2",
        "name": "${PORTAL_SSO_PROVIDER_NAME}",
        "description": "${PORTAL_SSO_PROVIDER_DESCRIPTION}",
        "buttonText": "${PORTAL_SSO_BUTTON_TEXT}",
        "authorizeEndpoint": "${PORTAL_SSO_AUTHORIZE_URL}",
        "tokenEndpoint": "${PORTAL_SSO_TOKEN_URL}",
        "userInfoEndpoint": "${PORTAL_SSO_USERINFO_URL}",
        "scope": [
          "read:user",
          "read:org"
        ]
      }
    ]
  },
  "pagination": {
    "size": {
      "default": 10,
      "values": [5, 10, 25, 50, 100]
    }
  }
}
