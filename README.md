# README

This repository holds the submission for the CS 1520 - Software Engineering course at the University of Pittsburgh.

## Overview

Iris is a physical therapy for mobile applications that tracks a user's movements and gives live feedback on form and movements for exercises. The Iris application is built using Flutter/Dart for Android devices and does not currently support iOS devices. There is a crude Python implementation stored in the `exercise_tester/` directory.

## Authors

This project is the culmination of effort from:
 - Michael Puthumana
 - Praz Nagarajan
 - Jett Weiss
 - Theo Zervos

## Installation

To install this project just clone the repository into your local machine.
```sh
git clone https://github.com/TheoZervos/iris-physical-therapy-assistant
```

## Pre-Requisites

In order to run the Iris Android application, one of the following requirements must be met.

### A. Running From an Emulator

To run Iris on your desktop/laptop, you must install Flutter and set up an Android emulator if you have not done so already. Follow the instructions below to set up an Android emulator for VSCode:

 1. Download and install VSCode for your target platform using the following the link: https://code.visualstudio.com/docs/setup/setup-overview 
 
 2.  Download and install Flutter for your target platform using the following link: https://docs.flutter.dev/install
 
 3. Install the Flutter extension on VSCode in the Extensions tab.
 
 4. Download and install Android Studio for your target platform using the following link: https://developer.android.com/studio
 
 5. Create an Android emulator: 
    - **Launch Android Studio**: Open the "Virtual Device Manager" from the welcome screen's More Actions menu or via **Tools > Device Manager** if a project is already open.
    - **Create Device**: Click the + or **Create Device** button.
    - **Select Hardware**: Choose a phone model (e.g., Pixel 7)
    - **Download System Image**: Select an Android version (e.g., API 33/34). If not already downloaded, click the Download icon next to the version name.
    - **Configure and Finish**: Adjust settings like RAM or internal storage if needed (optional), then click Finish.

- ***Note:*** *Iris uses Computer Vision to track the user's body. To get the best experience from Iris through an emulator ensure you allocate plenty of RAM to accomodate for the demanding CV calculations.*

### A. Running From an Android Device (Recommended)

It is recommended to run Iris using a physical Android device when possible. Follow the instructions below to set up your device to run with Iris:

 1. On your Android device, navigate to **Settings > About phone** and locate the **Build Number** option. 
      - This may be located in a deeper Setting like **Software Info** and can vary by Android version and phone brand.
 
 2. Tap the **Build Number** option 7 times until you see the message `You are now a developer!`.
 
 3. Return to the previous screen to find **Developer Options** at the bottom and ensure it is enabled.

## Running Iris

To run Iris, use the following command in the root directory of the project. Please understand that Iris may take a while to boot.
 
#### Using an Emulator
1. Find the ID of the emulator you wish to run Iris with by running `flutter emulators`.

2. Run the command `flutter emulators --launch <emulator_id>` to start the emulator. 

3. Once the emulator has fully started, run the **build.sh** (macOS/Linux) or the **build.bat** (Windows):
```sh
# macOS/Linux Command
sh build.sh

# Windows Command
.\build.bat
```

#### Using an External Android Device
1. Ensure that Developer Mode is turned on (follow the above instructions).

2. Plug your Android device into the device running Iris.
     - You may need to wait a few moments after connecting the device before running. You can check that the device is seen by running `flutter devices`

3. Run the **build.sh** (macOS/Linux) or the **build.bat** (Windows) file:
```sh
# macOS/Linux Command
sh build.sh

# Windows Command
.\build.bat
```

## Running the Python Exercise Tester

The Python exercise tester is a roughly made program that is the residual of an original backend. The instructions to start and configure the tester are within the `README` file inside of `exercise_tester`. Much of the tester will require manual configuration that may even require editing code to display certain metrics. The exercise tester is NOT a replacement or substitute for the Iris Flutter application.