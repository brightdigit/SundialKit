<p align="center">
    <img alt="MistKit" title="MistKit" src="Assets/logo.svg" height="200">
</p>
<h1 align="center"> SundialKit </h1>

Communications library across Apple platforms.

[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
[![Twitter](https://img.shields.io/badge/twitter-@brightdigit-blue.svg?style=flat)](http://twitter.com/brightdigit)
![GitHub](https://img.shields.io/github/license/brightdigit/MistKit)
![GitHub issues](https://img.shields.io/github/issues/brightdigit/MistKit)

[![macOS](https://github.com/brightdigit/MistKit/workflows/macOS/badge.svg)](https://github.com/brightdigit/MistKit/actions?query=workflow%3AmacOS)
[![ubuntu](https://github.com/brightdigit/MistKit/workflows/ubuntu/badge.svg)](https://github.com/brightdigit/MistKit/actions?query=workflow%3Aubuntu)
[![Travis (.com)](https://img.shields.io/travis/com/brightdigit/MistKit?logo=travis&?label=travis-ci)](https://travis-ci.com/brightdigit/MistKit)
[![Bitrise](https://img.shields.io/bitrise/b2595eab70c25d1b?logo=bitrise&?label=bitrise&token=rHUhEUFkU2RUL-KGmrKX1Q)](https://app.bitrise.io/app/b2595eab70c25d1b)
[![CircleCI](https://img.shields.io/circleci/build/github/brightdigit/MistKit?logo=circleci&?label=circle-ci&token=45c9ff6a86f9ac6c1ec8c85c3bc02f4d8859aa6b)](https://app.circleci.com/pipelines/github/brightdigit/MistKit)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FMistKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/MistKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FMistKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/MistKit)


[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/MistKit)](https://codecov.io/gh/brightdigit/MistKit)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/MistKit)](https://www.codefactor.io/repository/github/brightdigit/MistKit)
[![codebeat badge](https://codebeat.co/badges/c47b7e58-867c-410b-80c5-57e10140ba0f)](https://codebeat.co/projects/github-com-brightdigit-mistkit-main)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/brightdigit/MistKit)](https://codeclimate.com/github/brightdigit/MistKit)
[![Code Climate technical debt](https://img.shields.io/codeclimate/tech-debt/brightdigit/MistKit?label=debt)](https://codeclimate.com/github/brightdigit/MistKit)
[![Code Climate issues](https://img.shields.io/codeclimate/issues/brightdigit/MistKit)](https://codeclimate.com/github/brightdigit/MistKit)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)

![Demonstration of MistKit via Command-Line App `mistdemoc`](Assets/MistKitDemo.gif)


# Table of Contents

   * [**Introduction**](#introduction)
   * [**Features**](#features)
   * [**Installation**](#installation)
   * [**Usage**](#usage)
      * [Network Availability](#fetching-records-using-a-query-recordsquery)
      * [Watch Connectivity](#fetching-records-by-record-name-recordslookup)
      * [Examples](#examples)
      * [Further Code Documentation](#further-code-documentation)
   * [**Roadmap**](#roadmap)
      * [~~0.1.0~~](#010)
      * [~~0.2.0~~](#020)
      * [**0.4.0**](#040)
      * [0.6.0](#060)
      * [0.8.0](#080)
      * [0.9.0](#090)
      * [v1.0.0](#v100)
   * [**License**](#license)

# Introduction

_what does this do_
_why should you use_



### Demo Example

#### Sundial App

![Sample Schema for Todo List](Assets/CloudKitDB-Demo-Schema.jpg)

# Features 

Here's what's currently implemented with this library:

- [x] Composing Web Service Requests
- [x] Modifying Records (records/modify)
- [x] Fetching Records Using a Query (records/query)
- [x] Fetching Records by Record Name (records/lookup)
- [x] Fetching Current User Identity (users/caller)

# Installation

Swift Package Manager is Apple's decentralized dependency manager to integrate libraries to your Swift projects. It is now fully integrated with Xcode 11.

To integrate **MistKit** into your project using SPM, specify it in your Package.swift file:

```swift    
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/brightdigit/SundialKit.git", from: "0.2.0")
  ],
  targets: [
      .target(
          name: "YourTarget",
          dependencies: ["SundialKit", ...]),
      ...
  ]
)
```

# Usage 

## Composing Web Service Requests

## Further Code Documentation

[Documentation Here](/Documentation/Reference/README.md)

# Roadmap

<!-- https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/CloudKitWebServicesReference/index.html#//apple_ref/doc/uid/TP40015240-CH41-SW1 -->

## 0.1.0

- [x] Composing Web Service Requests
- [x] Modifying Records (records/modify)
- [x] Fetching Records Using a Query (records/query)
- [x] Fetching Records by Record Name (records/lookup)
- [x] Fetching Current User Identity (users/caller)

## 0.2.0 

- [x] Vapor Token Client
- [x] Vapor Token Storage
- [x] Vapor URL Client
- [x] Swift NIO URL Client
