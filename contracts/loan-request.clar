;; ---------------------------------------------------------
;; On-Chain Microloan Request System (OMRS)
;; Contract: loan-request.clar
;; ---------------------------------------------------------

;; -----------------------------
;; ADMIN & SETTINGS
;; -----------------------------
(define-data-var admin principal tx-sender)
;; Fixed uint literal by removing underscores - Clarity doesn't support underscores in numbers
(define-data-var max-loan uint u100000000) ;; e.g. 100 STX in micro-STX units
(define-data-var next-loan-id uint u1)

;; -----------------------------
;; STORAGE STRUCTURES
;; -----------------------------

(define-map loans uint {
  borrower: principal,
  amount: uint,
  approved: bool,
  repaid: bool,
  start-block: uint,
  repaid-block: uint
})

(define-map active-loans principal bool)

;; -----------------------------
;; ERROR CONSTANTS
;; -----------------------------
(define-constant ERR-INVALID-AMOUNT u110)
(define-constant ERR-AMOUNT-TOO-HIGH u111)
(define-constant ERR-ACTIVE-LOAN-EXISTS u112)
(define-constant ERR-NOT-FOUND u404)
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-ALREADY-APPROVED u113)
(define-constant ERR-NOT-APPROVED u114)
(define-constant ERR-ALREADY-REPAID u115)

;; -----------------------------
;; 1. Request Loan
;; -----------------------------
(define-public (request-loan (amount uint))
  (begin
    ;; Validate request
    (asserts! (> amount u0) (err ERR-INVALID-AMOUNT))
    (asserts! (<= amount (var-get max-loan)) (err ERR-AMOUNT-TOO-HIGH))
    (asserts! (is-none (map-get? active-loans tx-sender)) (err ERR-ACTIVE-LOAN-EXISTS))

    ;; Generate loan ID
    (let ((loan-id (var-get next-loan-id)))
      ;; Store loan data
      (map-set loans loan-id {
        borrower: tx-sender,
        amount: amount,
        approved: false,
        repaid: false,
        start-block: u0,
        repaid-block: u0
      })
      ;; Mark borrower as having an active loan
      (map-set active-loans tx-sender true)
      ;; Increment loan counter
      (var-set next-loan-id (+ loan-id u1))
      ;; Return loan ID
      (ok loan-id))))

;; -----------------------------
;; 2. Admin: Approve Loan
;; -----------------------------
(define-public (approve-loan (loan-id uint))
  (begin
    ;; Added admin authorization check
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-UNAUTHORIZED))
    
    ;; Fixed match syntax to use proper 4-argument form
    (match (map-get? loans loan-id)
      loan (begin
        (asserts! (not (get approved loan)) (err ERR-ALREADY-APPROVED))
        ;; Fixed map-set syntax - using proper Clarity merge syntax
        (map-set loans loan-id (merge loan { 
          approved: true, 
            start-block: u0 
        }))
        (ok true))
      (err ERR-NOT-FOUND))))

;; -----------------------------
;; 3. Repay Loan
;; -----------------------------
(define-public (repay-loan (loan-id uint))
  ;; Fixed match syntax to use proper 4-argument form without arrow syntax
  (match (map-get? loans loan-id)
    loan (begin
      ;; Added proper authorization and validation checks
      (asserts! (is-eq tx-sender (get borrower loan)) (err ERR-UNAUTHORIZED))
      (asserts! (get approved loan) (err ERR-NOT-APPROVED))
      (asserts! (not (get repaid loan)) (err ERR-ALREADY-REPAID))
      
      ;; Fixed map-set syntax using merge
      (map-set loans loan-id (merge loan { 
        repaid: true, 
          repaid-block: u0 
      }))
      ;; Remove active loan status
      (map-delete active-loans tx-sender)
      (ok true))
    (err ERR-NOT-FOUND)))

;; -----------------------------
;; 4. Read-only: Get Borrower Loan Status
;; -----------------------------
(define-read-only (has-active-loan (user principal))
  (ok (is-some (map-get? active-loans user))))

;; -----------------------------
;; 5. Read-only: Get Loan by ID
;; -----------------------------
(define-read-only (get-loan (loan-id uint))
  (match (map-get? loans loan-id)
    loan (ok loan)
    (err ERR-NOT-FOUND)))

;; -----------------------------
;; 6. Admin Functions
;; -----------------------------
(define-public (set-max-loan (new-max uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-UNAUTHORIZED))
    (var-set max-loan new-max)
    (ok true)))

(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-UNAUTHORIZED))
    (var-set admin new-admin)
    (ok true)))

;; -----------------------------
;; 7. Read-only: Get Contract Info
;; -----------------------------
(define-read-only (get-max-loan)
  (ok (var-get max-loan)))

(define-read-only (get-admin)
  (ok (var-get admin)))

(define-read-only (get-next-loan-id)
  (ok (var-get next-loan-id)))
