{
  "baseURL": "https://gravitee.teleport.app.suncoast.systems/management/organizations/DEFAULT/environments/DEFAULT/",
  "baseHref": "/",
  "authentication": {
    "oauth2": {
      "enabled": true,
      "clientId": "${PORTAL_OAUTH_CLIENT_ID}",
      "clientSecret": "${PORTAL_OAUTH_CLIENT_SECRET}",
      "serverURL": "${PORTAL_OAUTH_SERVER_URL}",
      "name": "${PORTAL_SSO_PROVIDER_NAME}",
      "description": "${PORTAL_SSO_PROVIDER_DESCRIPTION}",
      "buttonText": "${PORTAL_SSO_BUTTON_TEXT}",
      "authorizationEndpoint": "${PORTAL_SSO_AUTHORIZE_URL}",
      "tokenEndpoint": "${PORTAL_SSO_TOKEN_URL}",
      "userInfoEndpoint": "${PORTAL_SSO_USERINFO_URL}",
      "scope": [
        "read:user",
        "read:org"
      ]
    },
    "localLogin": {
      "enabled": true
    }
  },
  "scheduler": {
    "tasks": 10,
    "notifications": 10
  },
  "documentation": {
    "url": "https://docs.gravitee.io/"
  },
  "portal": {
    "apikeyHeader": "X-Gravitee-Api-Key",
    "devMode": false,
    "userCreation": {
      "enabled": false,
      "automaticValidation": {
        "enabled": false
      }
    },
    "support": {
      "enabled": true
    },
    "rating": {
      "enabled": true,
      "comment": {
        "mandatory": false
      }
    },
    "analytics": {
      "enabled": true,
      "trackingId": ""
    },
    "apis": {
      "tilesMode": {
        "enabled": true
      },
      "categoryMode": {
        "enabled": true
      },
      "promotedApiMode": {
        "enabled": true
      },
      "apiHeaderShowTags": {
        "enabled": true
      },
      "apiHeaderShowCategories": {
        "enabled": true
      }
    }
  }
}
