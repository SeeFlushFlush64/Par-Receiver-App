# Par-Receiver-App

![Static Badge](https://img.shields.io/badge/Flutter-blue) ![Static Badge](https://img.shields.io/badge/Firebase-yellow)

## CRUD Mobile Application for Registering COD and Non-COD Parcels

The **Par-Receiver Mobile App** allows users to register and manage COD and Non-COD parcels. Registered parcels serve as the basis for transactions with the Par-Receiver machine.

> **Warning**: I have deleted my `firebase_options.dart` and `google_services.json` files as they contain sensitive information (secrets). These files are required for the application to function properly.

Here is an [Audio-Visual Presentation](https://drive.google.com/file/d/1YCKJfx-oJFWOlZKkQbCbiCAsmtDB7QLt/view?usp=sharing) showing how the Par-Receiver Machine and the app work together.

---

## Features

- **Real-time Parcel Tracking**: Receive instant notifications when a parcel is received by the Par-Receiver machine.
- **Parcel Proof**: View a photo of your parcel captured by the ESP32 Camera inside the machine, ensuring secure delivery.
- **Cash Balance Display**: For COD deliveries, the app displays your current cash balance.
- **Cross-Platform Development**: Built using Flutter, making it compatible with both Android and iOS devices.
  
---

## Tech Stack & Explanation

This project introduced me to the world of **mobile app development**, an area that I had always been curious about.

- **Why Flutter?** While I initially considered Kotlin for Android and Swift for iOS development, I chose Flutter for its cross-platform capabilities, allowing me to build a single codebase for both platforms.
  
- **Firebase Integration**: The app uses Firebase for backend support, including real-time database management and storage of parcel images via Firebase Storage.
  
- **CRUD Operations**: The app allows users to perform CRUD (Create, Read, Update, Delete) operations to manage parcels efficiently.
  
- **USB Debugging**: Throughout the project, I worked extensively with USB debugging, enabling me to test the app on real devices during development.

This project was my first experience working with a cross-platform framework, which was both exciting and challenging. The transition from using Google Sheets to Firebase was a key improvement, as suggested during our title defense. Firebase provided a more scalable and secure solution for handling parcel data.

---

## Project Insights

The primary objective of this app was to fulfill the requirements for my Bachelor's Degree capstone project. However, as I progressed, I became increasingly passionate about enhancing the app's features. 

- Instead of just creating a basic CRUD app for parcel registration, I integrated a feature that displays proof of delivery by showing images captured by the ESP32 camera inside the Par-Receiver machine. This feature adds an extra layer of security and transparency for users, ensuring they have visual confirmation of parcel delivery.

This project allowed me to gain hands-on experience with mobile app development, Firebase, and cross-platform programming, and I’m proud of how it turned out. I continually sought ways to improve the app, ensuring it not only met the project requirements but also exceeded expectations in functionality and user experience.

---

## Screenshots

Here are some images of the Par-Receiver App in action:

### Parcel Registration

![Parcel Registration](path-to-your-image.jpg)

### Parcel Proof (ESP32 Camera Photo)

![Parcel Proof](path-to-your-image.jpg)

---

## License

This project is open-source and available under the [MIT License](LICENSE).
