# MailtoSpark

Redirects system `mailto:` links to Spark Mail (`com.readdle.smartemail`).

---

## Compatibility

* **iOS:** iOS 15.0 – iOS 18.x
* **Architecture:** `arm64` / `arm64e`
* **Jailbreak:** Rootless (Dopamine, Palera1n)
* **Dependency:** ElleKit

---

## Features

* System-wide `mailto:` link interception.
* Converts recipient, subject, body, CC, and BCC parameters to Spark's scheme (`readdle-spark://compose`).

---

## Installation

1. Download the latest `.deb` from [Releases](../../releases).
2. Install via **Sileo**, **Zebra**, or **Filza**.
3. Respring.

---

## Build

Uses **Theos** via GitHub Actions (`arm64`/`arm64e` rootless).
