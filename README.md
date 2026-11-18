# Smart Waste Guide — Android client

Flutter Android app for the CSS3344 Mobile Application Development assignment.

The app now has a reactive MVVM navigation shell, a home dashboard, login/registration screens, GPS-based nearby facility search, and a waste report form connected to the API.

For the Android emulator, the debug build uses the API at http://10.0.2.2:3000. Override it with --dart-define=API_BASE_URL=https://your-api-host when using a deployed HTTPS API. The bearer token stays in memory and is cleared on sign-out or app restart; secure persistent token storage is a later increment. Android Studio must resolve the geolocator and image_picker dependencies before building.

Nearby search requests foreground location only after the user taps “Use my location.” Coarse and precise Android permissions are declared together; background location is not requested.

The report form requires a category, a description between 10 and 500 characters, and a JPEG, PNG, or WebP photo under 1.5 MB. Photos can be selected from the camera or gallery and are compressed before upload. The API stores photo files separately from report metadata; administrators can view them and mark a report resolved or rejected.

## Required project components

- Login and registration backed by a signed-token API
- Reactive dashboard using MVVM
- GPS-based nearby recycling and disposal facilities
- Validated waste reports with camera and gallery images
- Offline data caching
- Asynchronous notifications
- Web admin interface and backend API
