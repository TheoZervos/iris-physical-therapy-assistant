# README

This repository holds Group 12's final project submission for the CS 1530 - Software Engineering course at the University of Pittsburgh.

## Overview

Iris is a physical therapy application for mobile devices that tracks a user's movements and gives live feedback on form and movements for exercises. The Iris application is built using Flutter/Dart for Android devices and does not currently support iOS devices. There is a crude Python implementation stored in the `exercise_tester/` directory.

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

 1. Download and install VSCode for your target platform using the following link: https://code.visualstudio.com/docs/setup/setup-overview 
 
 2.  Download and install Flutter for your target platform using the following link: https://docs.flutter.dev/install
 
 3. Install the Flutter extension on VSCode in the Extensions tab.
 
 4. Download and install Android Studio for your target platform using the following link: https://developer.android.com/studio
 
 5. Create an Android emulator: 
    - **Launch Android Studio**: Open the "Virtual Device Manager" from the welcome screen's More Actions menu or via **Tools > Device Manager** if a project is already open.
    - **Create Device**: Click the + or **Create Device** button.
    - **Select Hardware**: Choose a phone model (e.g., Pixel 7)
    - **Download System Image**: Select an Android version (e.g., API 33/34). If not already downloaded, click the Download icon next to the version name.
    - **Configure and Finish**: Adjust settings like RAM or internal storage if needed (optional), then click Finish.

- ***Note:*** *Iris uses Computer Vision to track the user's body. To get the best experience from Iris through an emulator ensure you allocate plenty of RAM to accommodate the high computation demand of CV calculations.*

### B. Running From an Android Device (Recommended)

It is recommended to run Iris using a physical Android device when possible. Follow the instructions below to set up your device to run with Iris:

 1. On your Android device, navigate to **Settings > About phone** and locate the **Build Number** option. 
      - This may be located in a deeper Setting like **Software Info** and can vary by Android version and phone brand.
 
 2. Tap the **Build Number** option 7 times until you see the message `You are now a developer!`.
 
 3. Return to the previous screen to find **Developer Options** at the bottom and ensure it is enabled.

 - ***Note*** *Older Android phones may have this setting visible by default. If yours does you only need to do step 3, enabling **Developer Options**.*

## Running Iris

To run Iris, use the following command in the root directory of the project. Please understand that Iris may take a while to boot especially on first boot.
 
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

2. Plug your Android device into the computer you are using to build Iris.
     - You may need to wait a few moments after connecting the device before running. You can check that the device is seen by running `flutter devices`

3. Run the **build.sh** (macOS/Linux) or the **build.bat** (Windows) file:
```sh
# macOS/Linux Command
sh build.sh

# Windows Command
.\build.bat
```

## Using Iris

### Starting Iris

Upon starting Iris you will be greeted by a screen with a list of exercises. As of the submission for this project the 4 exercises listed are:

 1. Single Arm Standing Row
 2. Lateral Raise
 3. Bicep Curl
 4. Shoulder Press

Along the bottom you will see a navigator that shows 3 tabs:

 1. Search
 2. Favorites
 3. History

The tab that Iris starts the user in is the Search tab.

### Exercise Search

In the exercise search tab you will see a list of exercises. Each exercise has a picture that represents what the exercise is, the exercise name, a list of muscles that the exercise targets, and a heart button. Clicking on the heart button will add the exercise to the user's favorites list. This list persists across runs of the app. Clicking anywhere else on the exercise list tile will take the user to an info screen that covers more detailed information about the exercise. This is also where the user starts tracking exercises.

### Exercise Info

Once the user has selected an exercise, Iris takes them to an exercise info page. The top bar of this page consists of a back button that returns the user to whatever page the user was on previously, the name of the exercise, and the heart button that the user can use to add the exercise to the favorites list.

The main content of the page displays a short instructional video on how to perform the exercise. Below the video is a text description on completing the exercise. Finally there is a Start Exercise button. Pressing this button will start the exercise tracking.

### Exercise Tracking

Once the user has started an exercise, the app will open up a tracking page. This page consists of a live camera feed of the user, an exercise feedback box, and a button to end the exercise. The feedback box will update in real time to provide exercise corrections and instructions to the user as they exercise. Once done with the exercise, the user presses the end exercise button and the exercise session is added to the user's history.

### The Favorites List

The Favorites tab displays all exercises that the user has favorited in a list. The list tiles work exactly the same as in exercise search. When an exercise is unfavorited from the favorites list while in the Favorites tab, the exercise disappears from the Favorites tab.

### Exercise History

The History tab showcases a list of past exercise sessions. These sessions are displayed in a list similar to the Favorites and Search tab, but they showcase their info differently. The far left showcases the date the exercise was completed (Month-Day on top, Year on bottom). The center shows the name of the exercise performed. Finally, the far right showcases the duration of the exercise (Minutes:Seconds). The exercise can track up to a maximum of `99:59` before the timer visually resets.

Short tapping on the list tile will take the user to the exercise's info page. Long pressing on the list tile will prompt the user asking if they would like to delete the exercise from their history. Deleting a past session in this way will remove the session from the History tab and the persistent user history. There is currently no way to undo a session deletion.

## Known Bugs

Below is a list of known bugs with the Iris application:

 1. Exercise sessions can only display a duration of up to `99:59`
     - Once `99:59` is reached, the displayed duration resets to `00:00`
          - The actual duration is still tracked properly, this is a visual bug

 2. The Lateral Raise exercise does not track properly

 3. Liking an exercise from its info page will cause the embedded video to rebuild itself again, causing a slight dip in performance

## Running the Python Exercise Tester

The Python exercise tester is a roughly made program that is the residual of an original backend. The instructions to start and configure the tester are within the `exercise_tyester/README.md` file. Much of the tester will require manual configuration that may even require editing code to display certain metrics. The exercise tester is NOT a replacement or substitute for the Iris Flutter application.