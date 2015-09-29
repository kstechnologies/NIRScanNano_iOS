# NIRScan Nano Project Description

The purpose of this project is to provide the simplest possible template for developers to create their own native iOS app for communicating with the Texas Instruments' NIRScan Nano Product.

This project allows the user to scan for and connect to the NanoScan using Bluetooth Low Energy (BLE).  It is feature poor, and the intent is for you to take the KSTNanoSDK.h/m files, add them to your own product, and use this SDK as an easy means of communicating with the NanoScan. 

Please consider searching on the TODO pragma marks throughout this code to see where we are taking it next. Our understanding of the NIRScan Nano, the firmware, the hardware, and the basic business logic of interacting with the device has all been under development and very dynamic.  There are "less than ideal" things in this source, but we believe it's in a great state to let you build great things!  Tell us what you're doing with this source via [email](mailto://sensing@kstechnologies.com)  or [Twitter](http://www.twitter.com/kstechnologies) .

# Compatibility

* Apple iOS 9.0+
* Requires Bluetooth Low Energy (BLE) Radio
* Requires TI NIRScanNano EVM running Firmware v1.1+

# Build Requirements

* CoreBluetooth.h
* KSTSpectrumLibrary.framework (1)
* ios-charts (2)

(1) In order to get the source code for the Spectrum C Library, you must execute a Non-Disclosure Agreement directly with Texas Instruments.
(2) This is an awesome open source project created by Daniel Cohen Gindi and is designed for building beautiful graphcs and charts for iOS.  Please see [Daniel's github repo](https://github.com/danielgindi/ios-charts) for more information.

If you just want to test out the app and get data as fast as possible, consider just downloading the compiled version of this app, [available for free on the iOS App Store](https://itunes.apple.com/us/app/nirscan-nano/id999810838?mt=8) .

# Version

*  Version 1.1.1, Build 14
*  iOS 9.0 SDK
*  Xcode Version 7.0 (7A220)

# Contact Information

Please [contact KST](mailto://sensing@kstechnologies.com) for any questions you may have regarding this SDK or for requesting custom hardware, firmware, app, or cloud development work based on TI's DLP Technology.  You can also [visit the KS Technologies website](http://www.kstechnologies.com) for more information about our company.

# FAQ

tbd

# License

Software License Agreement (BSD License)

Copyright (c) 2015, KS Technologies, LLC
All rights reserved.

Redistribution and use of this software in source and binary forms,
with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Neither the name of KS Technologies, LLC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission of KS Technologies, LLC.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
