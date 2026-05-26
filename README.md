# Savings Challenge Smart Contract

This project demonstrates a decentralized savings challenge system where users lock ERC-20 tokens into a smart contract and are financially incentivized to complete the challenge.
---

## Tech Stack

- Solidity ^0.8.20
- Ethereum
- ERC-20 Standard
- Remix IDE / Hardhat

## Contracts

### SavingsChallengeF

Main challenge contract.

### MockToken

Simple ERC-20-like token used for testing.

---

## How It Works

1. The contract owner deploys `SavingsChallengeF` with:
   - ERC-20 token address
   - registration duration
   - deposit amount
   - challenge duration

2. Users join before the registration deadline by depositing the required token amount.

3. Participants may forfeit before the challenge deadline.

4. After the challenge deadline:
   - the contract is finalized
   - non-forfeited users can claim their original deposit
   - forfeited deposits are split equally among finishers

---

## Main Functions

### `join()`

Allows a user to join the challenge.

#### Requirements
- Registration must still be open
- User must not have joined before
- User must approve the contract to spend `depositAmount`

---

### `forfeit()`

Allows a participant to forfeit before the challenge ends.

#### Effects
- Marks participant as forfeited
- Adds their deposit to the forfeited pool

---

### `finalize()`

Calculates how many participants completed the challenge.

#### Requirements
- Challenge deadline must have passed

---

### `claim()`

Allows successful participants to withdraw their reward.

#### Reward Formula

```solidity
paymentAmount = depositAmount + (forfeitedMoney / totalFinished);
```

#### Requirements
- Challenge must be over
- User must not have forfeited
- User must not have claimed before

---

### `getParticipants()`

Returns the list of all participants.

---

## Deployment Parameters

```solidity
constructor(
    address _token,
    uint256 _registrationDuration,
    uint256 _depositAmount,
    uint256 _challengeDuration
)
```

### Example

```solidity
SavingsChallengeF(
    mockTokenAddress,
    7 days,
    100 * 10**18,
    30 days
);
```

---

## Mock Token

`MockToken` gives the deployer an initial supply of:

```solidity
100000 * 10**18
```

### Supported Functions

- `transfer`
- `approve`
- `transferFrom`
- `balanceOf`
- `allowance`

---

## Basic Usage Flow

1. Deploy `MockToken`
2. Deploy `SavingsChallengeF` using the mock token address
3. Transfer tokens to test users
4. Each user calls:

```solidity
approve(challengeAddress, depositAmount);
```

5. Users call `join()`
6. Some users may call `forfeit()`
7. After the deadline, users call `claim()`

---

## Events

```solidity
event Joined(address participant, uint256 amount);
event Forfeited(address participant, uint256 amount);
event Claimed(address participant, uint256 paymentAmount);
event Finalized(
    uint256 totalFinished,
    uint256 forfeitedCount,
    uint256 forfeitedMoney
);
```

---

## Important Notes

This contract is suitable for learning and testing, but it is not production-ready.

### Issues to Fix Before Real Use

- No protection against fee-on-transfer tokens
- No SafeERC20 usage
- `finalize()` loops through all participants, which can become expensive
- Rounding dust from forfeited rewards stays in the contract
- `_depositAmount` can be zero
- `MockToken` is not a complete ERC-20 implementation

---

## License

MIT
