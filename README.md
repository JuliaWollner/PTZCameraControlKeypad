# PTZCameraControlKeypad

PTZ Camera control unit with a 4x4 Membrane Keypad

:warning: It is important to use an original Arduino, otherwise the UDEV-Rule doesn't work. :warning:

![alt text](https://github.com/JuliaWollner/PTZCameraControlKeypad/blob/master/images/title/image_01.jpg)


## Description

This repository contains all files you need to rebuild a camera controlling unit for the **Instar IN-9010 Full-HD** network camera. The control commands are sent via Common Gateway Interface (CGI). You can find the commands at the manufacturer's Wiki and the required material under the following [link](https://github.com/JuliaWollner/PTZCameraControlKeypad/blob/master/material/material.txt).

## Assembly

After 3D printing the enclosure of the keypad, it has to be assembled as shown in the [circuit schematic](https://github.com/JuliaWollner/PTZCameraControlKeypad/blob/master/circuit/circuit_1.png). The result should look like as follows:

<img align="center" src="https://github.com/JuliaWollner/PTZCameraControlKeypad/blob/master/images/title/image_02.jpg" width="415"> <img align="center" src="https://github.com/JuliaWollner/PTZCameraControlKeypad/blob/master/images/title/image_03.jpg" width="415">

## Preparing installation

For the installation we need the *„idVendor“*, the *„idProduct“* and the *„iSerial“* of the Arduino. For this we first enter the following command:

```
lsusb
```

As return you will receive the following entry, among others:

```
Bus 001 Device 004: ID 0403:6001 Future Technology Devices International, Ltd FT232 Serial (UART) IC
```

The displayed values **0403:6001** are the *"idVendor"* and the *"idProduct"*. Those are the same for every original Arduino Nano. You can read the *"iSerial"* as follows:

```
lsusb -vs 001:004
```

The values ***001*** correspond to the "Bus" and ***004*** to the "Device" returned above. Now you should see your *"iSerial"*.

```
A400MFLH
```

We keep in mind the values for the installation.

## Download

Clone the github repository and change to the new directory:
```
git clone https://github.com/JuliaWollner/PTZCameraControlKeypad
cd PTZCameraControlKeypad
```

## Installation

For installation enter the following commands and answer the queries:

```
chmod +x setup.sh
./setup.sh
```

## Usage

You will find the manual right [here](https://github.com/JuliaWollner/PTZCameraControlKeypad/tree/master/manual). In [Youtube](https://www.youtube.com/watch?v=fPmPj5Xyz6A) you can watch a video of the project.

