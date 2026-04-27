# Wayfarer - Your Ultimate Travel Companion

Wayfarer is a comprehensive travel management ecosystem designed to simplify every aspect of your journey. From planning intricate itineraries and tracking budgets to journaling memories and exploring new destinations with live maps, Wayfarer provides all the tools a modern traveler needs in one unified platform.

---

## Project Architecture

The Wayfarer ecosystem consists of three main components:

1.  **Backend (`/backend`):** A robust Node.js and Express server powered by MongoDB, providing centralized APIs for authentication, trip management, and external service proxies (Weather, Currency, Places, etc.).
2.  **Mobile App (`/wayfarer`):** A cross-platform mobile application built with Flutter, offering a seamless and intuitive user experience for travelers on the go.
3.  **Admin Dashboard (`/wayfarer_admin`):** A Flutter-based management interface for platform administrators to monitor activity and manage system resources.

---

## Key Features

-   **Smart Trip Planning:** Organize your itineraries, transport, and accommodations with ease.
-   **Budget & Expense Tracking:** Set budgets and track your spending in real-time to stay on top of your finances.
-   **Live Explorer:** Integrated maps (via Flutter Map) and location services to help you navigate and find points of interest.
-   **Travel Journal:** Capture your experiences with a digital diary, including images and notes.
-   **Travel Toolkit:**
    -   **Live Translation:** Break language barriers with integrated translation and Text-to-Speech.
    -   **Currency Converter:** Real-time exchange rate updates.
    -   **Weather Updates:** Stay prepared with localized weather forecasts.
    -   **Barcode Scanner:** Quick scanning for travel documents or information.

---

## Tech Stack

### Frontend (Mobile & Admin)
-   **Framework:** Flutter (Dart)
-   **State Management:** Provider
-   **Networking:** Dio
-   **Animations:** Flutter Animate, Shimmer
-   **Maps:** Flutter Map, Geolocator

### Backend
-   **Runtime:** Node.js
-   **Framework:** Express.js
-   **Database:** MongoDB (via Mongoose)
-   **Security:** JWT Authentication, Rate Limiting, CORS
