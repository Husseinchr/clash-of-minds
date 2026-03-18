<div align="center">

# ⚔️ Clash of Minds

### Real-Time Team-Based Quiz Tournament Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.10.8+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

*Battle of intellects where teams compete in epic quiz showdowns!*

[Features](#-features) • [Installation](#-installation) • [Architecture](#-architecture)

</div>

---

## 📖 Overview

**Clash of Minds** is a sophisticated real-time multiplayer quiz tournament application built with Flutter and Firebase. Players form teams of up to 3 members each, compete in fast-paced trivia battles, and track their performance through comprehensive match history.

### 🎯 Key Highlights

- 🔥 **Real-time multiplayer** gameplay with Firestore
- 👥 **Team-based competition** (up to 6 players per match)
- 🎮 **Leader-managed matches** with question control
- 💬 **Team private chat** for strategy discussions
- 🏆 **Match history** with detailed statistics
- 👤 **Profile customization** with image uploads
- 👫 **Friends system** with invitations
- 🎨 **Clean architecture** following SOLID principles

---

## ✨ Features

### 🔐 Authentication & Profiles
- ✅ Google Sign-In integration (Firebase Auth)
- ✅ Automatic user profile creation
- ✅ Custom display names
- ✅ Profile picture upload to Firebase Storage
- ✅ Persistent authentication state

### 🎮 Match System

#### Creating & Joining Matches
- ✅ **Create matches** with unique 4-digit codes
- ✅ **Join via code** or **direct invitations**
- ✅ **Smart team selection** - choose your team or auto-assign
- ✅ **Team invitations** - invite friends to specific matches
- ✅ **Flexible team sizes** - 1v1, 2v2, 3v3 matches
- ✅ **Real-time lobby** with live player updates

#### Gameplay - Leader View
- ✅ Send questions to all players
- ✅ Provide hints after questions
- ✅ Evaluate answers (correct/wrong)
- ✅ Dismiss questions (skip)
- ✅ Real-time score tracking
- ✅ Team turn management (15-second turn timer)
- ✅ End match functionality

#### Gameplay - Player View
- ✅ View current questions and hints
- ✅ **Team turn system** - only your team can answer during your turn
- ✅ **First-to-press answering** - race to claim the question
- ✅ 15-second answer timer
- ✅ Team identification with color coding
- ✅ Real-time score updates
- ✅ System messages for match events

### 💬 Team Communication
- ✅ **Private team chat** during matches
- ✅ Real-time message synchronization
- ✅ Team-isolated conversations
- ✅ Keyboard-aware message input
- ✅ Persistent chat history during match

### 👫 Friends System
- ✅ Send friend requests by display name
- ✅ Accept/decline requests
- ✅ Friends list management
- ✅ Real-time status updates
- ✅ Invite friends to matches
- ✅ Match invitation inbox

### 📊 Match History
- ✅ **Complete match archive** with all past games
- ✅ **Detailed statistics** - scores, teams, duration
- ✅ **Win/loss tracking** with visual indicators
- ✅ **Team rosters** showing all participants
- ✅ **Personal highlights** - your team emphasized
- ✅ **Relative timestamps** ("2 hours ago", "Yesterday")
- ✅ Pull-to-refresh for latest matches

### 🔄 Real-Time Features
- ✅ Live match updates via Firestore streams
- ✅ Instant score synchronization
- ✅ Real-time player actions
- ✅ Match status changes
- ✅ Friend requests and updates
- ✅ Team chat messages
- ✅ Automatic team turn switching

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                           # Shared utilities and infrastructure
│   ├── constants/                  # App-wide constants
│   │   └── app_constants.dart      # Firebase collections, limits, etc.
│   ├── di/                         # Dependency injection
│   │   └── injection_container.dart# GetIt service locator setup
│   ├── error/                      # Error handling
│   │   ├── exceptions.dart         # Custom exceptions
│   │   └── failures.dart           # Failure types
│   ├── extensions/                 # Dart extensions
│   │   └── context_extensions.dart # BuildContext helpers
│   ├── theme/                      # App theming
│   │   └── app_theme.dart          # Colors, text styles
│   └── widgets/                    # Reusable UI components
│       ├── custom_button.dart
│       ├── loading_overlay.dart
│       └── profile_image_widget.dart
│
├── features/                       # Feature modules
│   ├── auth/                       # Authentication
│   │   ├── data/
│   │   │   ├── datasources/        # Firebase Auth API
│   │   │   ├── models/             # User model
│   │   │   └── repositories/       # Repository implementation
│   │   ├── domain/
│   │   │   ├── entities/           # User entity
│   │   │   ├── repositories/       # Repository interface
│   │   │   └── usecases/           # Sign in/out, get user
│   │   └── presentation/
│   │       ├── bloc/               # Auth BLoC
│   │       └── screens/            # Login, display name setup
│   │
│   ├── profile/                    # User profile management
│   ├── match/                      # Match system (create, join, play)
│   ├── friends/                    # Friends management
│   ├── chat/                       # Team chat
│   └── history/                    # Match history
│
├── routes/                         # App navigation
│   └── app_routes.dart
│
└── main.dart                       # App entry point
```

### Layer Responsibilities

#### 🎨 Presentation Layer
- **UI Components**: Screens, widgets
- **State Management**: flutter_bloc pattern
- **Events**: User interactions
- **States**: UI state representations

#### 💼 Domain Layer
- **Entities**: Core business objects
- **Use Cases**: Business logic operations
- **Repository Interfaces**: Data contracts
- **No dependencies** on outer layers

#### 💾 Data Layer
- **Models**: JSON serializable data structures
- **Data Sources**: Firebase, API implementations
- **Repository Implementations**: Use case fulfillment
- **Error Handling**: Exception → Failure conversion

---

## 🛠️ Tech Stack

### Frontend
| Technology | Purpose |
|-----------|---------|
| ![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white) | Cross-platform UI framework |
| ![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white) | Programming language |
| ![BLoC](https://img.shields.io/badge/BLoC-Pattern-blue) | State management |

### Backend
| Service | Purpose |
|---------|---------|
| ![Firebase Auth](https://img.shields.io/badge/Firebase_Auth-FFCA28?logo=firebase) | User authentication |
| ![Firestore](https://img.shields.io/badge/Firestore-FFCA28?logo=firebase) | Real-time database |
| ![Storage](https://img.shields.io/badge/Firebase_Storage-FFCA28?logo=firebase) | File storage |

### Key Packages

```yaml
dependencies:
  # Firebase
  firebase_core: ^3.8.0
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.0

  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.7

  # Dependency Injection
  get_it: ^8.0.2
  injectable: ^2.5.0

  # Utilities
  dartz: ^0.10.1              # Functional programming
  uuid: ^4.5.1                # Unique IDs
  intl: ^0.19.0               # Internationalization

  # UI
  cached_network_image: ^3.4.1
  image_picker: ^1.1.2
  google_sign_in: ^6.2.2
```

---

## 📊 Database Schema

### Firestore Collections

#### `users` Collection
```javascript
{
  "uid": "user123",
  "email": "player@example.com",
  "displayName": "PlayerOne",
  "profilePicture": "https://storage...",
  "createdAt": Timestamp
}
```

#### `matches` Collection
```javascript
{
  "id": "match123",
  "code": "1234",                     // 4-digit code
  "leaderId": "user123",
  "leaderName": "PlayerOne",

  // Teams (up to 3 players each)
  "team1PlayerIds": ["user1", "user2", "user3"],
  "team2PlayerIds": ["user4", "user5", "user6"],

  // Scores
  "team1Score": 5,
  "team2Score": 3,

  // Status
  "status": "inProgress",             // waiting | inProgress | completed

  // Current Question
  "currentQuestion": "What is 2+2?",
  "currentHint": "It's between 3 and 5",
  "currentAnswerer": "user2",         // Currently answering player
  "currentAnswererName": "PlayerTwo",
  "currentAnswer": "4",
  "answerStartTime": Timestamp,       // 15-second timer

  // Team Turn System
  "currentTeamTurn": 1,               // 1 or 2 (null = both)
  "teamTurnStartTime": Timestamp,
  "teamTurnVersion": 3,               // Prevent race conditions

  // System Messages
  "systemMessages": ["Match started", "Team 1's turn"],

  // Timestamps
  "createdAt": Timestamp,
  "startedAt": Timestamp,
  "completedAt": Timestamp
}
```

#### `match_invitations` Collection
```javascript
{
  "id": "invite123",
  "matchId": "match123",
  "matchCode": "1234",
  "fromUserId": "user1",
  "fromUserName": "Leader",
  "toUserId": "user2",
  "toUserName": "Friend",
  "status": "pending",                // pending | accepted | declined | expired
  "createdAt": Timestamp,
  "expiresAt": Timestamp,             // 24 hours
  "respondedAt": Timestamp
}
```

#### `chats` Collection (Subcollection Structure)
```javascript
// chats/{matchId}/teams/{teamNumber}/messages/{messageId}
{
  "id": "msg123",
  "senderId": "user1",
  "senderName": "PlayerOne",
  "content": "Good luck!",
  "sentAt": Timestamp
}
```

#### `history` Collection
```javascript
{
  "id": "match123",
  "matchCode": "1234",
  "leaderId": "user1",
  "leaderName": "Leader",

  // Participants
  "team1PlayerIds": ["user1", "user2"],
  "team2PlayerIds": ["user3", "user4"],
  "participantIds": ["user1", "user2", "user3", "user4"],
  "playerNames": {
    "user1": "PlayerOne",
    "user2": "PlayerTwo",
    "user3": "PlayerThree",
    "user4": "PlayerFour"
  },

  // Results
  "team1Score": 5,
  "team2Score": 3,
  "winningTeam": 1,                   // 1, 2, or 0 (tie)

  // Timestamps
  "createdAt": Timestamp,
  "startedAt": Timestamp,
  "completedAt": Timestamp
}
```

#### `friend_requests` Collection
```javascript
{
  "id": "req123",
  "fromUserId": "user1",
  "fromUserName": "PlayerOne",
  "fromUserPhoto": "https://...",
  "toUserId": "user2",
  "toUserName": "PlayerTwo",
  "status": "pending",                // pending | accepted | declined
  "createdAt": Timestamp
}
```

#### `users/{userId}/user_friends` Subcollection
```javascript
{
  "uid": "friend123",
  "displayName": "FriendName",
  "profilePicture": "https://...",
  "addedAt": Timestamp
}
```

---

## 🚀 Installation

### Prerequisites
- Flutter SDK **3.10.8** or later
- Dart SDK **3.0.0** or later
- Android Studio / VS Code with Flutter extensions
- Firebase account
- Git

### Step 1: Clone Repository

```bash
git clone https://github.com/Husseinchr/clash-of-minds.git
cd clash-of-minds
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Firebase Setup

#### 3.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add Project**
3. Enter project name: `clash-of-minds`
4. Enable Google Analytics (optional)
5. Create project

#### 3.2 Enable Firebase Services

**Authentication:**
1. Navigate to **Authentication** → **Get Started**
2. Enable **Google** sign-in provider
3. Add support email

**Firestore Database:**
1. Navigate to **Firestore Database** → **Create Database**
2. Start in **Production Mode**
3. Choose your region
4. Click **Enable**

**Firebase Storage:**
1. Navigate to **Storage** → **Get Started**
2. Start in **Production Mode**
3. Click **Done**

#### 3.3 Register Apps

**For Android:**
1. Click **Add App** → **Android**
2. Package name: `com.MobahasatKitab.tournament`
3. Download `google-services.json`
4. Place in `android/app/`

**For iOS:**
1. Click **Add App** → **iOS**
2. Bundle ID: `com.MobahasatKitab.tournament`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/`

#### 3.4 Configure Firebase CLI (Optional)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
firebase init
```

### Step 4: Update Security Rules

#### Firestore Rules

Navigate to **Firestore Database** → **Rules** and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isOwner(userId);
      allow delete: if isOwner(userId);
    }
    match /matches/{matchId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated();
      allow delete: if isAuthenticated();
      
      match /team1_chat/{messageId} {
        allow read, write: if isAuthenticated();
      }
      
      match /team2_chat/{messageId} {
        allow read, write: if isAuthenticated();
      }
    }
    match /match_invitations/{invitationId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() &&
                       request.resource.data.fromUserId == request.auth.uid;
      allow update: if isAuthenticated() &&
                       resource.data.toUserId == request.auth.uid;
      allow delete: if isAuthenticated() &&
                       (resource.data.toUserId == request.auth.uid ||
                        resource.data.fromUserId == request.auth.uid);
    }
    match /friends/{userId}/user_friends/{friendId} {
      allow read: if isAuthenticated() &&
                     (userId == request.auth.uid || friendId == request.auth.uid);
      allow create, update, delete: if isAuthenticated() && 
        (userId == request.auth.uid || friendId == request.auth.uid);
    }
    match /friend_requests/{requestId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() &&
                      request.resource.data.fromUserId == request.auth.uid;
      allow update: if isAuthenticated() &&
                      resource.data.toUserId == request.auth.uid;
      allow delete: if isAuthenticated() &&
                      (resource.data.fromUserId == request.auth.uid ||
                        resource.data.toUserId == request.auth.uid);
    }
    match /{path=**}/user_friends/{friendId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
    
    match /history/{historyId} {
      allow read: if request.auth != null && 
        request.auth.uid in resource.data.participantIds;
      allow create: if request.auth != null;
      allow update, delete: if false;
    }
  }
}
```

### Step 5: Create Required Indexes

Some Firestore queries require composite indexes. When you first run certain features, Firestore will show errors with links to create indexes. Required indexes examples:

1. **History Collection:**
   - Fields: `participantIds` (Array), `completedAt` (Descending)
   - Scope: Collection

2. **Match Invitations:**
   - Fields: `toUserId` (Ascending), `status` (Ascending), `createdAt` (Descending)
   - Scope: Collection

Click the provided links in error messages to auto-create these indexes.

### Step 6: Run the App

```bash
# Analyze code
flutter analyze

# Run on connected device
flutter run

```

---

## 🎮 User Guide

### Getting Started

1. **Sign In**
   - Launch app
   - Tap "Sign in with Google"
   - Select your Google account

2. **Create a Match**
   - Tap **Create Match** on home screen
   - Share the 4-digit code with players
   - Wait in lobby as players join
   - Tap **Start Match** when ready

3. **Join a Match**
   - Tap **Join Match** on home screen
   - Enter the 4-digit code
   - Select your preferred team or auto-assign
   - Wait for leader to start

### Playing as Leader

1. **Send Questions**
   - Type your question in the text field
   - Tap **Send Question**
   - Players can now compete to answer

2. **Provide Hints** (Optional)
   - Type a hint
   - Tap **Send Hint**

3. **Evaluate Answers**
   - When a player answers, tap:
     - **✓ Correct** - Award point to their team
     - **✗ Wrong** - Switch turn to other team
     - **Dismiss** - Skip question (no points)

4. **End Match**
   - Tap **End Match** when finished
   - Match automatically saved to history

### Playing as Player

1. **Wait for Your Team's Turn**
   - Watch the 15-second timer
   - Only answer when it's your team's turn

2. **Answer Questions**
   - Tap **Answer Question** to claim
   - Type your answer
   - Tap **Submit Answer**
   - Wait for leader evaluation

3. **Use Team Chat**
   - Tap **Team Chat** button
   - Coordinate strategy with teammates
   - Messages are team-private

### Managing Friends

1. **Send Friend Request**
   - Tap **Friends** → **Add Friend**
   - Enter their exact display name
   - Tap **Send Request**

2. **Accept Requests**
   - Tap **Friends** → **Requests** tab
   - Tap **Accept** or **Decline**

3. **Invite to Match**
   - In match lobby, tap **Invite Friends**
   - Select friends to invite
   - They receive notifications

### Viewing History

1. **Access History**
   - Tap **History** icon on home screen
   - See all completed matches

2. **View Match Details**
   - Tap any match card
   - See final scores, team rosters, and statistics
   - Win/loss highlighted for your team

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📦 Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output locations:
# APK: build/app/outputs/flutter-apk/app-release.apk
# Bundle: build/app/outputs/bundle/release/app-release.aab
```

### Release Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Run `flutter analyze` (zero issues)
- [ ] Run all tests
- [ ] Test on physical devices (Android & iOS)
- [ ] Update Firestore security rules
- [ ] Update Storage security rules
- [ ] Create release notes
- [ ] Tag release in Git

---

## 🐛 Troubleshooting

### Common Issues

**1. Firebase not initialized**
```
Error: [core/no-app] No Firebase App has been created
```
**Solution:**
- Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in correct location
- Run `flutter clean && flutter pub get`
- Rebuild app

**2. Google Sign-In fails**
```
Error: PlatformException(sign_in_failed)
```
**Solution:**
- Add SHA-1 certificate to Firebase project:
  ```bash
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey
  ```
- Add SHA-1 in Firebase Console → Project Settings → SHA certificate fingerprints
- Download new `google-services.json`

**3. Firestore permission denied**
```
Error: [cloud_firestore/permission-denied]
```
**Solution:**
- Check Firestore security rules
- Ensure user is authenticated
- Verify rules allow the operation

**4. Match code not working**
```
Error: Match not found
```
**Solution:**
- Verify 4-digit code is correct
- Check match hasn't ended
- Ensure match document exists in Firestore

**5. Team chat not loading**
```
Error: Messages not appearing
```
**Solution:**
- Check Firestore rules for chats collection
- Verify user is in the match
- Check network connection

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Clash of Minds

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🗺️ Roadmap

### Version 2.0 (Upcoming)

- [ ] 🌍 Internationalization (multiple languages)
- [ ] 🎨 Custom themes and dark mode
- [ ] 📊 Advanced statistics and leaderboards
- [ ] 🏅 Achievement system
- [ ] 🔔 Push notifications
- [ ] 🎯 Question categories and difficulty levels
- [ ] 📸 Question image support
- [ ] 🎵 Sound effects and music
- [ ] 📱 Tablet UI optimization
- [ ] 🌐 Web platform support

### Future Considerations

- Tournament brackets
- Spectator mode
- Question bank management
- Custom match settings
- Replay system
- Social sharing

---

<div align="center">

### Built with ❤️ using Flutter and Firebase

**[⬆ back to top](#-clash-of-minds)**

</div>
