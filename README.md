# Swifty Companion 

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![42 Network](https://img.shields.io/badge/42-Network-black?style=for-the-badge)

A beautifully crafted Flutter application that acts as a companion for students of the 42 Network. It utilizes the official 42 API to provide seamless access to student profiles, campus information, and project statuses.

##  Features

- **OAuth2 Authentication**: Secure login using the official 42 intra credentials.
- **My Profile**: View your own 42 profile details at a glance.
- **Campus Directory**: Browse users currently active on your campus.
- **User Search**: Quickly find and view public profiles of other 42 students.
- **Project Tracking**: See detailed information about user projects, including completed and failed ones.

##  Screenshots

*(Replace these with actual screenshots of your application)*
| Login | Home | Profile |
| :---: | :---: | :---: |
| <img src="assets/logo/icon.png" width="200"/> | <img src="assets/logo/icon.png" width="200"/> | <img src="assets/logo/icon.png" width="200"/> |

##  Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.12.0 or higher)
- A 42 Intra API application (to get your `UID` and `SECRET`)

### Installation

1. **Clone the repository**
   ```sh
   git clone https://github.com/AnasBouzanbil/Swifty-Companion.git
   cd Swifty-Companion
   ```

2. **Install dependencies**
   ```sh
   flutter pub get
   ```

3. **Set up Environment Variables**
   Create a `.env` file in the root directory and add your 42 API credentials:
   ```env
   UID=your_42_api_uid_here
   SECRET=your_42_api_secret_here
   CALLBACK_URL=your_callback_url_here
   ```

4. **Run the app**
   ```sh
   flutter run
   ```

##  Built With

* [Flutter](https://flutter.dev/) - UI Toolkit
* [Provider](https://pub.dev/packages/provider) - State Management
* [HTTP](https://pub.dev/packages/http) - Network Requests
* [Flutter Web Auth 2](https://pub.dev/packages/flutter_web_auth_2) - OAuth Authentication
* [Flutter Dotenv](https://pub.dev/packages/flutter_dotenv) - Environment Configuration

##  42 API Endpoints Used

### OAuth2
- `GET /oauth/authorize` - Opens the 42 login/consent page.
- `POST /oauth/token` - Exchanges the authorization code for an access token or refreshes an expired one.

### API v2
- `GET /v2/me` - Fetches the currently authenticated user profile.
- `GET /v2/campus/{campus_id}/users` - Loads the campus users list.
- `GET /v2/users` - Searches users by login.
- `GET /v2/users/{login}` - Fetches full public profile data of a selected user.
- `GET /v2/users/{login}/projects_users` - Fetches all user projects with pagination.

##  Notes

- Base URL used for v2 endpoints: `https://api.intra.42.fr/v2`
- OAuth host used: `https://api.intra.42.fr`
- Authentication header used for v2 calls: `Authorization: Bearer <access_token>`

---
*Made  by [Anas Bouzanbil](https://github.com/AnasBouzanbil)*
