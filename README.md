# swiftycompanion

Swifty Companion app built with Flutter using the 42 API.

## 42 API Endpoints Used

### OAuth2

- `GET /oauth/authorize`
  - Description: Opens the 42 login/consent page and returns an authorization code to the app callback URI.

- `POST /oauth/token` (`grant_type=authorization_code`)
  - Description: Exchanges the authorization code for an access token (and refresh token).

- `POST /oauth/token` (`grant_type=refresh_token`)
  - Description: Refreshes an expired/expiring access token using the stored refresh token.

### API v2

- `GET /v2/me`
  - Description: Fetches the currently authenticated user profile for the "My Profile" screen.

- `GET /v2/campus/{campus_id}/users?per_page=30&sort=-updated_at`
  - Description: Loads the campus users list shown on the Home tab.

- `GET /v2/users?filter[login]={query}&per_page=10&sort=login`
  - Description: Searches users by login from the Search tab.

- `GET /v2/users/{login}`
  - Description: Fetches full public profile data of a selected user.

- `GET /v2/users/{login}/projects_users?page[number]={page}&page[size]=100`
  - Description: Fetches all user projects (including failed ones) with pagination until all pages are loaded.

## Notes

- Base URL used for v2 endpoints: `https://api.intra.42.fr/v2`
- OAuth host used: `https://api.intra.42.fr`
- Authentication header used for v2 calls: `Authorization: Bearer <access_token>`
