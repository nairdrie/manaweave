# ManaWeave

Unleash your inner planeswalker with this Commander deck-builder app, featuring a sleek, card-centric UI, intelligent autofill, and a delightful bulk card scanning experience to help you conquer the multiverse!

## Getting Started

To get a local copy up and running follow these simple example steps.

### Prerequisites

You need to have Flutter installed on your machine. If you don't have it, you can follow the official installation guide:

*   [Install Flutter](https://docs.flutter.dev/get-started/install)

### Installation

1.  Clone the repo. You will need to replace `your_username/manaweave.git` with the actual path to the repository.
    ```sh
    git clone https://github.com/your_username/manaweave.git
    ```
2.  Navigate to the project directory
    ```sh
    cd manaweave
    ```
3.  Install packages
    ```sh
    flutter pub get
    ```
4.  Run the app
    ```sh
    flutter run
    ```

### Firebase Setup

This project uses Firebase for its backend. You will need to set up your own Firebase project and configure it for this app to work.

1.  Go to the [Firebase console](https://console.firebase.google.com/) and create a new project.
2.  Follow the instructions to add an Android and/or iOS app to your Firebase project.
3.  You will need to add the `google-services.json` file for Android and `GoogleService-Info.plist` file for iOS to the project. You can find more information on how to do this in the [FlutterFire documentation](https://firebase.flutter.dev/docs/overview).
