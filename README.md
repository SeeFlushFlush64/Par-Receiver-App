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

![mockup-login](https://github.com/user-attachments/assets/f848b1ee-8c2e-4259-aec3-db4e34ef8b03)

![Pixel 8 Pro Mockup Obsidian](https://github.com/user-attachments/assets/a03776a6-87c7-4ac8-a04d-97848e9c94eb)

![mockup-dashboard](https://github.com/user-attachments/assets/6fcfa574-e419-4878-a5f7-1e3d1ddbea5d)

![Pixel 8 Pro Mockup Obsidian_A](https://github.com/user-attachments/assets/82a9f7cd-eeec-432e-b3c3-8b91cdb8eb6a)

![1720012826696](https://github.com/user-attachments/assets/720b107a-23bd-43b5-b69d-e01595ef3f7c)

![Pixel 8 Pro Mockup Obsidian_C](https://github.com/user-attachments/assets/131f5e57-d2bf-4e90-a60a-4aac0a37244d)

![1720012826720](https://github.com/user-attachments/assets/12bb3a3b-c484-4339-98fc-4e23eeaba2d7)

![1720013001782](https://github.com/user-attachments/assets/d231ec02-3115-4e88-a0ce-1d169e4decba)

![1720019918040](https://github.com/user-attachments/assets/7a64bcb4-559b-4fdf-a831-e06cdac6aafd)

![1720020137287](https://github.com/user-attachments/assets/8c7bdd55-2d57-4f48-b4b7-d43bd4532856)

![1720020137259](https://github.com/user-attachments/assets/1ea8b9f1-65dc-484b-ae65-67c44b60d760)

![mockup-about](https://github.com/user-attachments/assets/944af4d6-b6a2-4443-8f85-aeaee3d2549f)



---

## License

This project is open-source and available under the [MIT License](LICENSE).
