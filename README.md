# VideoConference - Flutter WebRTC App

A modern, feature-rich video conferencing application built with Flutter and WebRTC, similar to Zoom with teacher-student functionality.

## Features

### 🔐 Authentication
- **Teacher/Student Registration**: Role-based user registration
- **Login System**: Secure authentication for registered users
- **Guest Access**: Non-registered users can join meetings as guests
- **Profile Management**: Update user profiles and settings

### 📹 Meeting Management
- **Create Meetings**: Teachers can create and schedule meetings
- **Instant Meetings**: Start meetings immediately
- **Join Meetings**: Join via Meeting ID, passcode, or direct link
- **Meeting Settings**: Configure audio/video permissions, waiting rooms, etc.
- **Meeting History**: View past and upcoming meetings

### 🎥 Video Conferencing
- **High-Quality Video/Audio**: WebRTC-based real-time communication
- **Multi-Participant Support**: Connect multiple participants
- **Camera Controls**: Switch between front/back camera, mute/unmute
- **Screen Sharing**: Share screen content (feature ready)
- **Meeting Recording**: Record meetings (feature ready)
- **Participant Management**: View and manage participants

### 🎨 Modern UI/UX
- **Material Design**: Clean, intuitive interface
- **Dark/Light Theme**: Automatic theme switching
- **Responsive Layout**: Adapts to different screen sizes
- **Real-time Updates**: Live meeting status and participant updates

## Screenshots

*Note: Add screenshots of your app here*

## Getting Started

### Prerequisites

- Flutter 3.16.0 or higher
- Dart 3.2.0 or higher
- Android Studio / VS Code
- Physical device (recommended for WebRTC testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repository-url>
   cd get_boilerplate
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure permissions**
   
   For Android, ensure these permissions are in `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
   <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
   ```

   For iOS, add these to `ios/Runner/Info.plist`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>This app needs camera access to make video calls</string>
   <key>NSMicrophoneUsageDescription</key>
   <string>This app needs microphone access to make audio calls</string>
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── src/
    ├── controllers/          # GetX controllers
    │   ├── auth_controller.dart
    │   ├── meeting_controller.dart
    │   └── ...
    ├── models/              # Data models
    │   ├── user_model.dart
    │   ├── meeting_model.dart
    │   └── ...
    ├── pages/               # UI screens
    │   ├── auth/            # Login/Register pages
    │   ├── dashboard/       # Home dashboard
    │   ├── meeting/         # Meeting-related pages
    │   └── ...
    ├── routes/              # App navigation
    ├── services/            # External services
    ├── repository/          # Data layer
    │   ├── local/           # Local storage
    │   └── remote/          # API calls
    ├── theme/               # App theming
    ├── utils/               # Utility functions
    └── shared/              # Shared components
```

### Key Technologies
- **Flutter**: UI framework
- **GetX**: State management, routing, dependency injection
- **flutter_webrtc**: WebRTC implementation
- **socket_io_client**: Real-time communication
- **get_storage**: Local data persistence

## Configuration

### Backend Setup

1. **Socket Server**: Configure your WebRTC signaling server URL in:
   ```dart
   // lib/src/pages/home/home_page.dart
   const urlConnectSocket = 'https://your-server.com';
   ```

2. **API Endpoints**: Update API base URL in:
   ```dart
   // lib/src/repository/base_repository.dart
   const String rootUrl = "your-api-domain.com";
   ```

3. **TURN/STUN Servers**: Configure ICE servers in:
   ```dart
   // lib/src/pages/home/home_page.dart
   Map<String, dynamic> configuration = {
     'iceServers': [
       {"urls": "stun:stun.l.google.com:19302"},
       // Add your TURN servers here
     ],
   };
   ```

## Usage

### For Teachers
1. **Register/Login** as a teacher
2. **Create Meeting**: Set title, schedule, and configure settings
3. **Share Meeting**: Copy meeting ID/link and share with students
4. **Start Meeting**: Begin the video conference
5. **Manage Participants**: Control audio/video permissions

### For Students
1. **Register/Login** as a student or continue as guest
2. **Join Meeting**: Enter meeting ID or click invitation link
3. **Enter Name** (for guests)
4. **Configure Audio/Video**: Choose initial settings
5. **Join Conference**: Participate in the meeting

### Meeting Controls
- **Mute/Unmute**: Toggle microphone
- **Video On/Off**: Toggle camera
- **Switch Camera**: Front/back camera
- **Screen Share**: Share your screen
- **End Call**: Leave the meeting

## API Integration

The app is designed to work with a backend API. Key endpoints needed:

```
POST /api/auth/login          # User login
POST /api/auth/register       # User registration
GET  /api/meetings           # Get user meetings
POST /api/meetings           # Create new meeting
PUT  /api/meetings/:id       # Update meeting
DELETE /api/meetings/:id     # Delete meeting
```

## WebRTC Signaling

The app uses Socket.IO for WebRTC signaling. Required events:

```javascript
// Client to Server
- join-meeting
- offer
- answer
- ice-candidate
- leave-meeting

// Server to Client
- participant-joined
- participant-left
- offer
- answer
- ice-candidate
```

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Device Testing
- Test on physical devices for camera/microphone functionality
- Test network connectivity in different conditions
- Test with multiple participants

## Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Troubleshooting

### Common Issues

1. **Camera/Microphone not working**
   - Check device permissions
   - Test on physical device (not simulator)
   - Verify permission declarations

2. **WebRTC connection fails**
   - Check STUN/TURN server configuration
   - Verify network connectivity
   - Check firewall settings

3. **Build issues**
   - Run `flutter clean && flutter pub get`
   - Check Flutter version compatibility
   - Verify all dependencies are up to date

### Debug Tools
- Enable WebRTC logging for detailed connection info
- Use Flutter Inspector for UI debugging
- Check browser console for web version

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Roadmap

- [ ] Group chat functionality
- [ ] File sharing during meetings
- [ ] Meeting recordings
- [ ] Virtual backgrounds
- [ ] Whiteboard feature
- [ ] Breakout rooms
- [ ] Calendar integration
- [ ] Mobile app notifications
- [ ] Web version support

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Create an issue on GitHub
- Email: support@yourapp.com
- Documentation: [Wiki](link-to-wiki)

## Acknowledgments

- Flutter team for the amazing framework
- flutter_webrtc plugin contributors
- GetX community for state management
- Material Design for UI guidelines

---

**Note**: This is a starter template. Customize the configuration, styling, and features according to your specific needs.