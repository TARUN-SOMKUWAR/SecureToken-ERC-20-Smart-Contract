# SecureToken-ERC-20-Smart-Contract
Wrote an ERC-20 token contract from scratch in Solidity, deployed and verified on the Ethereum Sepolia testnet (0x02C38...dA9F). Source code publicly verified against on-chain bytecode via Sourcify. 

Documented security considerations including access control and the Checks-Effects-Interactions pattern.

SecureToken — A Hand-Written ERC-20 Token in Solidity

A from-scratch implementation of the ERC-20 token standard, written without importing external libraries, so every function's logic and security reasoning is fully understood rather than trusted from a dependency.

Deployed on Sepolia Testnet: 0x02C38b6383D03deb6257AEcCd6Cf2126048edA9F

View on Sepolia Etherscan
Verified source on Sourcify (Exact Match — source code publicly verified against on-chain bytecode)
Features
Full ERC-20 interface: transfer, approve, transferFrom, balanceOf, allowance
Owner-restricted mint function
Standard Transfer, Approval, and Mint events
Security Considerations
Access Control: Minting is restricted to the contract owner via an onlyOwner modifier, preventing unauthorized supply inflation.
Checks-Effects-Interactions: All balance/allowance updates happen before any event emission, and the contract makes no external calls — eliminating reentrancy risk for every state-changing function.
Zero-address guards: Transfers, approvals, and minting all reject the zero address to prevent accidental token burns via a typo'd address.
Known limitation (documented, not "hidden"): The approve function has the standard ERC-20 front-running caveat when changing a non-zero allowance directly. Production tokens typically add increaseAllowance/decreaseAllowance to mitigate this — omitted here to keep the base contract focused and teachable.
Tech Stack
Solidity ^0.8.20
Deployed and tested via Remix IDE + MetaMask on Sepolia testnet
How to Deploy This Yourself
Open Remix IDE
Paste SecureToken.sol into a new file
Compile with Solidity 0.8.20
Deploy via "Injected Provider - MetaMask" on Sepolia, passing an initial supply (e.g. 1000000) to the constructor
What I Learned

Writing an ERC-20 token from scratch (rather than importing OpenZeppelin) forced a deeper understanding of exactly where access control and reentrancy risks come from, not just how to call a library's functions.
