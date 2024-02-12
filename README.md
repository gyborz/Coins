# Coins

Coins is an iOS app for tracking the top 10 crypto currencies in the market.

## Overview

Coins was built using:
- Xcode 15.1
- Swift 5.9
- UIKit
- MVVM

The project can be also built and run via Xcode 14.3 and earlier versions of Swift. The minimum deployment target is iOS 16.0.
The architecture relies heavily on Combine and Swift Concurrency. The project was built in a way so it can scale, there are several base classes and a few utilities to support building different layers of UI, providers, repositories and agents.

There were no third party dependencies used.

#
API used for getting cryptocurreny market data:
- [coincap api](https://docs.coincap.io/) (used without token)

Since I couldn't find any image data in the coincap api I simply hardcoded a free alternative called [placekitten](https://placekitten.com/).

Poppins fonts was downloaded from [googlefonts](https://fonts.google.com/specimen/Poppins).

## Getting Started

Simply clone the repo or download it as a zip and open Coins.xcodeproj file with Xcode. 

There's only one scheme and two targets. Just build and run the Coins scheme.

Even though there's no MOCK compile flag and target it's distinguished in code in DI.
