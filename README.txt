====================================================
CHURCH APP - DEPLOYMENT & USAGE GUIDE
====================================================

This project is a full iOS/Android + backend app for 
church worship & sermon projection.

FEATURES:
- OCR for sermon notes & music sheets
- Song & lyrics scheduling
- Pastor notes with live editing, reordering, timing
- Service Display (projector output)
- Auto-scroll with customizable intervals
- Toggle auto-scroll for pastor notes
- Chromecast + AirPlay/Web projection
- Real-time refresh when pastor edits notes
- Docker Compose deployment with PostgreSQL + Node.js
- Automatic HTTPS (Let's Encrypt)
- GitHub Actions CI/CD auto-deployment

----------------------------------------------------
1. PREREQUISITES
----------------------------------------------------
Server Requirements:
- Ubuntu 20.04+ (recommended)
- Docker & Docker Compose installed
- Domain name pointed to server IP (A record)
- GitHub repository for CI/CD

Client Requirements:
- Flutter SDK installed (for building mobile app)
- Android Studio or Xcode (for iOS/Android builds)

----------------------------------------------------
2. BACKEND SETUP (Docker + SSL)
----------------------------------------------------
1. Clone repo to server:
   sudo mkdir -p /opt/church-app
   cd /opt/church-app
   git clone git@github.com:yourusername/church-app.git .

2. Update docker-compose.yml:
   - Replace "yourdomain.com" with your actual domain
   - Replace "admin@yourdomain.com" with a valid email
   - Set DB_USER / DB_PASS if you want custom creds

3. Run the stack:
   docker-compose up -d --build

4. Check containers:
   docker ps

5. Verify API:
   https://yourdomain.com

6. Access Receivers:
   Chromecast → https://yourdomain.com/receiver/receiver.html
   AirPlay/Web → https://yourdomain.com/airplay.html

----------------------------------------------------
3. DATABASE SCHEMA
----------------------------------------------------
Database: PostgreSQL
Tables:
- songs
- services
- service_songs
- pastor_notes (content, display_time, position)

Schema auto-applies on first run.

----------------------------------------------------
4. MOBILE APP SETUP (Flutter)
----------------------------------------------------
1. Update API URL:
   In mobile/lib/service_screen.dart
   Replace "http://localhost:4000" with
   "https://yourdomain.com"

2. Install deps:
   cd mobile
   flutter pub get

3. Run on device:
   flutter run

4. Build production:
   - Android: flutter build apk --release
   - iOS: flutter build ios --release

----------------------------------------------------
5. FEATURES USAGE
----------------------------------------------------
- OCR Notes → Capture sermon notes via camera
- OCR Music → Upload sheet music, convert to MusicXML
- Admin Add Song → Add songs/lyrics
- Pastor Notes Screen:
  - Add/edit notes for a service
  - Drag & drop reorder
  - Change display times live
  - Delete notes
- Service Display:
  - Shows unified queue (songs + notes)
  - Auto-scroll ON/OFF
  - Notes auto-scroll toggle
  - Chromecast / AirPlay projection

----------------------------------------------------
6. CHROMCAST & AIRPLAY
----------------------------------------------------
- Chromecast:
  Tap "Cast to Chromecast" in Service Display
  Projector shows lyrics/notes
- AirPlay/Web:
  Open https://yourdomain.com/airplay.html
  iOS: Share or AirPlay to projector

----------------------------------------------------
7. AUTO-SCROLL SETTINGS
----------------------------------------------------
- Default 10s per slide
- Settings screen lets worship leader change interval
- Notes respect their own display_time
- Notes can ignore auto-scroll if toggle OFF

----------------------------------------------------
8. REAL-TIME REFRESH
----------------------------------------------------
- If pastor edits notes (text, timing, or order),
  Service Display reloads instantly
- No restart required

----------------------------------------------------
9. CI/CD WITH GITHUB ACTIONS
----------------------------------------------------
1. Push repo to GitHub
2. Add GitHub secrets:
   - SERVER_IP (server IP)
   - SERVER_USER (ssh user, e.g. ubuntu)
   - SERVER_SSH_KEY (private key content)
3. On push to main branch:
   - GitHub SSH into server
   - Pulls latest code
   - Restarts Docker stack

----------------------------------------------------
10. FIRST SUNDAY TEST RUN
----------------------------------------------------
1. Load songs & pastor notes into app
2. Start backend (docker-compose up -d)
3. Connect projector:
   - Chromecast → receiver.html
   - AirPlay → airplay.html
4. Open Service Display on leader’s phone
5. Walk through worship set:
   - Verify auto-scroll works
   - Verify notes display
   - Test live editing of notes
6. Preach with confidence 🎉

----------------------------------------------------
TROUBLESHOOTING
----------------------------------------------------
- No lyrics on projector:
  Check backend logs: docker-compose logs -f backend
- SSL issues:
  Ensure DNS points to server & ports 80/443 are open
- Mobile app fails:
  Confirm API URL matches https://yourdomain.com
- Notes not refreshing:
  Check SSE endpoint /notes-stream is open


----------------------------------------------------
11. HDMI PROJECTION (Fallback Option)
----------------------------------------------------
1. Connect your phone, tablet, or laptop to the projector/TV with an HDMI cable.
2. Open Service Display in the app.
3. Tap the TV icon in the top bar → "Presentation Mode".
4. Projector shows fullscreen lyrics/notes with no controls.
