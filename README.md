# 🌍 Wayfarer - Your Ultimate Travel Companion

Wayfarer is a comprehensive travel management ecosystem designed to simplify every aspect of your journey. From planning intricate itineraries and tracking budgets to journaling memories and exploring new destinations with live maps, Wayfarer provides all the tools a modern traveler needs in one unified platform.

---

## 🏗️ Project Architecture

The Wayfarer ecosystem consists of three main components:

1.  **🚀 Backend (`/backend`):** A robust Node.js and Express server powered by MongoDB, providing centralized APIs for authentication, trip management, and external service proxies.
2.  **📱 Mobile App (`/wayfarer`):** A cross-platform mobile application built with Flutter, offering a seamless and intuitive user experience for travelers on the go.
3.  **🛠️ Admin Dashboard (`/wayfarer_admin`):** A Flutter-based management interface for platform administrators to monitor activity and manage system resources.

---

## ✨ Key Features

-   **📅 Smart Trip Planning:** Organize your itineraries, transport, and accommodations with ease.
-   **💰 Budget & Expense Tracking:** Set budgets and track your spending in real-time to stay on top of your finances.
-   **🗺️ Live Explorer:** Integrated maps (via Flutter Map) and location services to help you navigate and find points of interest.
-   **📝 Travel Journal:** Capture your experiences with a digital diary, including images and notes.
-   **🧰 Travel Toolkit:**
    -   **🗣️ Live Translation:** Break language barriers with integrated Google Translation and Text-to-Speech.
    -   **💱 Currency Converter:** Real-time exchange rate updates with cost-of-living insights.
    -   **🌦️ Weather Updates:** Stay prepared with localized weather forecasts and air quality data.
    -   **🔍 Barcode Scanner:** Quick scanning for travel documents or information.

---

## 🔌 Integrated Services & APIs

Wayfarer leverages industry-standard APIs to provide real-time data:

| Category | Service Providers |
| :--- | :--- |
| **Maps & Places** | [OpenStreetMap](https://www.openstreetmap.org/) (Nominatim), [Overpass API](https://overpass-turbo.eu/), [OpenRouteService](https://openrouteservice.org/), [Photon](https://photon.komoot.io/) |
| **Weather** | [Open-Meteo](https://open-meteo.com/), [WeatherAPI.com](https://www.weatherapi.com/), [SunriseSunset.io](https://sunrisesunset.io/) |
| **Finance** | [Frankfurter API](https://www.frankfurter.app/), [Teleport API](https://developers.teleport.org/), Currency-API |
| **Translation** | [Google Translate API](https://cloud.google.com/translate) |
| **Country Info** | [Rest Countries API](https://restcountries.com/) |

---

## 💻 Tech Stack

### 📱 Frontend (Mobile & Admin)
-   **Framework:** Flutter (Dart)
-   **State Management:** Provider
-   **Networking:** Dio
-   **Animations:** Flutter Animate, Shimmer
-   **Maps:** Flutter Map, Geolocator
-   **Storage:** Shared Preferences

### ⚙️ Backend
-   **Runtime:** Node.js
-   **Framework:** Express.js
-   **Database:** MongoDB (via Mongoose)
-   **Security:** JWT Authentication, Rate Limiting, CORS
-   **Utilities:** Axios, Caching (In-memory)

---

## 🛠️ Getting Started

### Prerequisites
-   [Flutter SDK](https://docs.flutter.dev/get-started/install)
-   [Node.js](https://nodejs.org/) (v16+)
-   [MongoDB](https://www.mongodb.com/)

### Installation
1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Rayhan-Arrazy/Wayfarer-Travel.git
    cd Wayfarer-Travel
    ```
2.  **Setup Backend:**
    ```bash
    cd backend
    npm install
    # Create a .env file based on .env.example
    npm start
    ```
3.  **Setup Mobile App:**
    ```bash
    cd wayfarer
    flutter pub get
    flutter run
    ```

---

## 📄 License
This project is licensed under the **ISC License**. See the `package.json` for details.

---
*Created with ❤️ by the Wayfarer Team*
