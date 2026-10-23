# MailtoSpark

If you previously uninstalled Apple’s Mail app, you might find this popup frustratingly familiar:

<img width="828" height="497" alt="image" src="https://github.com/user-attachments/assets/5c012e78-0b81-4d28-9c6a-94135cd049fd" />

This tweak redirects system `mailto:` links to Spark Mail (`com.readdle.smartemail`).

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
