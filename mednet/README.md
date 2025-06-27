# MedNet

**MedNet** is a decentralized smart contract platform built on the Stacks blockchain that empowers medical researchers and healthcare professionals to collaborate, publish, and peer-review medical research transparently and securely.

## 🚀 Features

- **Researcher Registration:** Healthcare professionals can register themselves with verified profiles.
- **Profile Management:** Researchers can update their specialization and institutional affiliations.
- **Publication Submission:** Users can submit research publications, including titles, abstracts, and journals.
- **Peer Review System:** Decentralized peer-review mechanism for validating submitted publications.
- **Expertise Review:** Colleagues can provide reviews of a researcher's domain expertise.
- **Research Collaborations:** Enables mutual, bidirectional recording of research collaborations.
- **Transparent Read Access:** Public read-only access to researcher profiles, peer reviews, publication statuses, and collaboration states.

## 🔐 Access Control

- Only unregistered users can register as new researchers.
- Only registered researchers can submit publications or perform reviews.
- Self-review and duplicate collaborations are strictly prevented.

## 📚 Smart Contract Overview

### Data Structures

- `researchers`: Stores researcher profiles by principal.
- `publications`: Tracks submitted research and peer review metadata.
- `peer-reviews`: Records expertise-based peer reviews.
- `collaborations`: Records mutual collaborations between two researchers.

### Key Constants

- `err-admin-only`: Unauthorized admin action.
- `err-researcher-not-found`: Invalid researcher reference.
- `err-duplicate-entry`: Duplicate registration detected.
- `err-invalid-action`: Invalid self or logic violation in action.

## 🛠️ Public Functions

- `register-researcher(...)`
- `update-researcher-info(...)`
- `submit-publication(...)`
- `peer-review-publication(...)`
- `review-expertise(...)`
- `start-collaboration(...)`

## 🔍 Read-Only Functions

- `get-researcher-profile(...)`
- `get-publication-details(...)`
- `are-collaborating(...)`
- `get-peer-review(...)`
- `is-publication-reviewed(...)`
- `get-next-publication-id()`

## 🧪 Example Use Case

1. Dr. Alice registers on the network.
2. She submits a paper titled *"Gene Therapy Advancements"*.
3. Dr. Bob, her colleague, reviews and approves her publication.
4. They start a collaboration for future research.

#