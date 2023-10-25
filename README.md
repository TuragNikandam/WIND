<p align="center">
  <img src="Media/WIND_LOGO.png" width="400" height="400">
</p>

# W. I. N. D. (Wählen, Informieren, Netzwerken, Diskutieren)

## Overview
Emerging from the Andromeda project, W. I. N. D. serves as an intricate platform designed for voting, information dissemination, networking, and topical discussions.

## Authors
- [@TuragNikandam](https://www.github.com/TuragNikandam)
- [@MalteHein](https://www.github.com/MalteHein)

## Features
- **Vote**: Robust voting functionalities across diverse topics.
- **Inform**: Timely dissemination of news and updates.
- **Network**: Facilities for member-to-member connectivity.
- **Discuss**: A forum dedicated to open and constructive discussions.

## Technology Stack
**Frontend**: Implemented as a cross-platform application for iOS and Android, utilizing pure [Flutter](https://flutter.dev/) written in Dart.

**Additional Frontend Libraries**: flutter_secure_storage, email_validator, intl, logger, among others.

**Backend**: Utilizes Node.js and Express.js for server-side operations.

**Additional Backend Libraries**: Mongoose, Helmet, JWT, Winston, etc.

**Database**: MongoDB

## Demo
To Be Determined (TBD)

## Installation

### Prerequisites
- Node.js
- Flutter SDK
- Android Studio or XCode with a functional Emulator/Simulator
- MongoDB Atlas

### Installation Steps
1. Clone the repository
```bash
git clone https://github.com/TuragNikandam/WIND.git
```
2. Transition to the backend directory and execute npm install
```bash
cd WIND/WebServer/AndromedaAPI/api
npm install
```
3. Populate a .env file with the following information
```bash
# JWT Configuration
JWT_SECRET=YourJWTSecret
JWT_EXPIRATION_TIME=1h

# Server Port
PORT=localhost (commonly 3000)

# Operating Environment
NODE_ENV=either 'production' or 'development'

# Database Credentials
DB_USER=DBUSER
DB_PASSWORD=DBPASSWORD
DB_NAME=Either 'ProdDB' or 'TestDB'
```
4. The server (server.js) looks for key und certificate files in order to enable HTTPS. In the current implementation, those can either be self signed (usually not recommended), signed by an trusted authority or not signed at all using HTTP instead of HTTPS. The last approach is not recommended, but can be used if the handling of the HTTPS protocol is done by another service (like nginx). Provide these files in the designated directory:
```bash
cd WIND/WebServer/HttpsConfig
# Add AndromedaWebServerKey.pem and AndromedaWebServerCERT.pem
```
If alternative configurations are preferred, omit the key and certificate files.

5. Navigate to the mobile app directory and initiate package retrieval
```bash
cd WIND/Mobile/wind
flutter pub get
```
6. Validate the appropriate URLs for Android and iOS in both development and production configurations.
If you use a dedicated server to run the Node backend you need to specify the path to that server in the app config.
7. Commence the MongoDB service.
8. Initialize the backend server
```bash
node server.js
```
9. Launch your emulator for Android or simulator for iOS.
10. Run the mobile app
```bash
flutter run
```

### Usage
1. Backend: Developed using Express.js, the backend interfaces with MongoDB and incorporates JWT for authentication alongside Helmet for enhanced security. It is fully equipped to operate on a server as a Node.js API.
2. Mobile App: Build with Flutter and Dart, the application resembles a social media platform. Users can inform, discuss, and network among other functionalities.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Contact
For more information, please contact the contributors / owner.
