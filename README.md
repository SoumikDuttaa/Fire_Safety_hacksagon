# Fire_Safety_hacksagon
Fire Safety App – FlamoBot & AR Training System

An AI-powered fire safety training solution built using Flutter, Google Gemini, and Firebase. Developed during Hacksagon as part of Team NNC.

# Overview

This project offers hotel staff and industrial workers an interactive way to learn fire emergency protocols through:

Real-time AI ChatBot named Flamo

AR-based fire extinguisher usage simulation

AI-generated quizzes and performance reports

Visual drill progress dashboard

Firebase Auth and Firestore integration

# Features

Flamo AI ChatBot

Responds naturally to fire safety–related queries

Image input support for visual queries

Memory-aware responses

Uses Gemini 1.5 Pro API

Augmented Reality (AR) Drill Trainer

Embedded APK for Android

Demonstrates fire extinguishing technique step-by-step

Interactive visuals and safety dialogue

Quiz & Report Generator

Auto-generates quizzes from video content

AI evaluates answers and identifies weak areas

Printable PDF performance reports

Admin Dashboard

Manage staff profiles and shifts

Track drill performance

Monitor quiz results

# Tech Stack

Component : Technology
Frontend : Flutter 3.7
Backend : Firebase (Auth, Firestore)
AI Model : Google Gemini (via google_generative_ai Dart SDK)
AR : Android APK (Unity-based)
Analytics : Fl_chart, Circular indicators

# Folder Structure

fire_safety_app/
├── lib/
│ ├── chatbot/ (Chat UI and logic)
│ ├── dashboard/ (Admin and User dashboards)
│ ├── models/ (User, Appointment, Quiz)
│ ├── pages/ (Login, Profile, AR, Appointments)
│ └── firebase_options.dart
├── assets/
│ ├── flamoBot.png
│ └── Fire AR.apk
├── android/
│ ├── app/
│ │ └── google-services.json
│ └── build.gradle.kts
└── pubspec.yaml

# How to Run

Flutter App:

Navigate to the project directory

Run:
cd fire_safety_app
flutter pub get
flutter run

Note:
Ensure Firebase is configured properly and an internet connection is available for Gemini API access.

AR APK:
Install from the path:
fire_safety_app/android/app/src/main/assets/Fire AR.apk

Team NNC – Hacksagon Submission

Member : Role
Arnav Chauhan : ML, AR, Fire Safety Domain
Pragyan Diwakar : Firebase Backend, UI/UX, Navigation
Soumik Dutta : Flutter & API Integration

License

This project is developed as part of a hackathon and is open for academic and demonstrative purposes only.
