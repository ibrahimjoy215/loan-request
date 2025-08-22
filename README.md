Overview

The Loan Request Contract is a Clarity smart contract that enables borrowers to submit loan requests transparently on the Stacks blockchain.

It serves as the first step in a decentralized lending process by recording borrower requests on-chain, which can later be reviewed and approved by validators in the Loan Approval contract.

This project is designed for submission under Code for STX
.

Problem

Traditional lending systems are centralized and opaque, making it difficult for borrowers to have equal access to credit. There is a need for a transparent loan request mechanism where applications are visible and verifiable on-chain.

Solution

The Loan Request Contract provides a decentralized loan submission system where:

Borrowers can request a loan by specifying the amount and purpose.

Loan requests are stored on-chain and assigned unique IDs.

Validators or lenders can later review requests for approval/rejection.

All submissions are transparently auditable on the blockchain.

Core Features

Loan Request Submission – borrowers submit loan requests with amount and purpose.

Unique Request IDs – every loan request is tracked for reference.

Event Logging – submissions are recorded for transparency and external monitoring.

Foundation for Loan Approval – integrates with Loan Approval contracts to complete the lending lifecycle.

Tech Stack

Smart Contract: Clarity

Testing: Clarinet

Frontend (Optional Demo): React + Stacks.js + Hiro Wallet
