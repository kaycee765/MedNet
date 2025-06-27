;; Medical Research Network Smart Contract
;; Decentralized platform for medical researchers and healthcare professionals

;; Constants
(define-constant network-admin tx-sender)
(define-constant err-admin-only (err u200))
(define-constant err-researcher-not-found (err u201))
(define-constant err-duplicate-entry (err u202))
(define-constant err-invalid-action (err u203))

;; Data Variables
(define-data-var next-researcher-id uint u1)
(define-data-var next-publication-id uint u1)

;; Data Maps
(define-map researchers
  { doctor: principal }
  {
    full-name: (string-ascii 60),
    specialty: (string-ascii 80),
    institution: (string-ascii 200),
    registered-at: uint
  }
)

(define-map publications
  { publication-id: uint }
  {
    author: principal,
    research-title: (string-ascii 150),
    journal: (string-ascii 100),
    abstract: (string-ascii 500),
    peer-reviewed: bool,
    reviewer: (optional principal),
    published-at: uint
  }
)

(define-map peer-reviews
  { reviewer: principal, reviewed: principal, research-area: (string-ascii 60) }
  {
    review-notes: (string-ascii 300),
    review-date: uint
  }
)

(define-map collaborations
  { researcher-alpha: principal, researcher-beta: principal }
  { active: bool, started-at: uint }
)

;; Public Functions

;; Register as a medical researcher
(define-public (register-researcher (full-name (string-ascii 60)) (specialty (string-ascii 80)) (institution (string-ascii 200)))
  (let ((doctor tx-sender))
    (asserts! (is-none (map-get? researchers { doctor: doctor })) err-duplicate-entry)
    (map-set researchers
      { doctor: doctor }
      {
        full-name: full-name,
        specialty: specialty,
        institution: institution,
        registered-at: block-height
      }
    )
    (ok true)
  )
)

;; Update researcher information
(define-public (update-researcher-info (full-name (string-ascii 60)) (specialty (string-ascii 80)) (institution (string-ascii 200)))
  (let ((doctor tx-sender))
    (asserts! (is-some (map-get? researchers { doctor: doctor })) err-researcher-not-found)
    (map-set researchers
      { doctor: doctor }
      {
        full-name: full-name,
        specialty: specialty,
        institution: institution,
        registered-at: block-height
      }
    )
    (ok true)
  )
)

;; Submit a research publication
(define-public (submit-publication (research-title (string-ascii 150)) (journal (string-ascii 100)) (abstract (string-ascii 500)))
  (let 
    (
      (publication-id (var-get next-publication-id))
      (author tx-sender)
    )
    (asserts! (is-some (map-get? researchers { doctor: author })) err-researcher-not-found)
    (map-set publications
      { publication-id: publication-id }
      {
        author: author,
        research-title: research-title,
        journal: journal,
        abstract: abstract,
        peer-reviewed: false,
        reviewer: none,
        published-at: block-height
      }
    )
    (var-set next-publication-id (+ publication-id u1))
    (ok publication-id)
  )
)

;; Peer review a publication
(define-public (peer-review-publication (publication-id uint) (author principal))
  (let 
    (
      (publication (unwrap! (map-get? publications { publication-id: publication-id }) err-researcher-not-found))
      (reviewer tx-sender)
    )
    (asserts! (is-eq (get author publication) author) err-invalid-action)
    (map-set publications
      { publication-id: publication-id }
      (merge publication { 
        peer-reviewed: true, 
        reviewer: (some reviewer) 
      })
    )
    (ok true)
  )
)

;; Review colleague's research expertise
(define-public (review-expertise (reviewed principal) (research-area (string-ascii 60)) (review-notes (string-ascii 300)))
  (let ((reviewer tx-sender))
    (asserts! (is-some (map-get? researchers { doctor: reviewer })) err-researcher-not-found)
    (asserts! (is-some (map-get? researchers { doctor: reviewed })) err-researcher-not-found)
    (asserts! (not (is-eq reviewer reviewed)) err-invalid-action)
    (map-set peer-reviews
      { reviewer: reviewer, reviewed: reviewed, research-area: research-area }
      {
        review-notes: review-notes,
        review-date: block-height
      }
    )
    (ok true)
  )
)

;; Start research collaboration
(define-public (start-collaboration (colleague principal))
  (let ((researcher tx-sender))
    (asserts! (is-some (map-get? researchers { doctor: researcher })) err-researcher-not-found)
    (asserts! (is-some (map-get? researchers { doctor: colleague })) err-researcher-not-found)
    (asserts! (not (is-eq researcher colleague)) err-invalid-action)
    (map-set collaborations
      { researcher-alpha: researcher, researcher-beta: colleague }
      { active: true, started-at: block-height }
    )
    (map-set collaborations
      { researcher-alpha: colleague, researcher-beta: researcher }
      { active: true, started-at: block-height }
    )
    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-researcher-profile (doctor principal))
  (map-get? researchers { doctor: doctor })
)

(define-read-only (get-publication-details (publication-id uint))
  (map-get? publications { publication-id: publication-id })
)

(define-read-only (are-collaborating (researcher-alpha principal) (researcher-beta principal))
  (default-to false (get active (map-get? collaborations { researcher-alpha: researcher-alpha, researcher-beta: researcher-beta })))
)

(define-read-only (get-peer-review (reviewer principal) (reviewed principal) (research-area (string-ascii 60)))
  (map-get? peer-reviews { reviewer: reviewer, reviewed: reviewed, research-area: research-area })
)

(define-read-only (is-publication-reviewed (publication-id uint))
  (match (map-get? publications { publication-id: publication-id })
    publication (get peer-reviewed publication)
    false
  )
)

(define-read-only (get-next-publication-id)
  (var-get next-publication-id)
)