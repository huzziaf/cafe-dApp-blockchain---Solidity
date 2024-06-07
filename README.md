# Decentralized FAST Cafeteria Shopping App
This project is a decentralized application (DAPP) designed to revolutionize the way students and staff interact with the cafeteria at FAST University. The system provides a seamless and transparent experience for ordering meals, processing transactions, handling payments via a custom cryptocurrency called FastCoin, and rewarding loyal customers. The DAPP utilizes multiple smart contracts to manage various functionalities such as menu management, order processing, payments, loyalty rewards, and promotions.

## Project Overview

### Smart Contracts

1. **FastCoin (ERC20 Token)**
   - Implements FastCoin adhering to the ERC20 token standard.
   - Facilitates payments, loyalty rewards, and promotions within the cafeteria system.

2. **MenuManagement**
   - Manages the cafeteria menu, including items, prices, and availability.
   - Allows cafeteria staff to add new menu items, update prices, and check item availability.

3. **Promotions**
   - Manages discounts and special promotions.
   - Allows cafeteria staff to set discounts and apply them to orders.

4. **RewardsLoyalty**
   - Establishes a rewards and loyalty program.
   - Credits loyalty tokens to users based on their purchasing behavior.
   - Allows users to redeem loyalty tokens for prizes.

5. **OrderContract**
   - Facilitates the order processing system.
   - Calculates the total order amount, applies discounts, and processes payments.

## Technologies Used

- **Solidity**: For writing smart contracts.
- **Ganache**: For local blockchain development.
- **MetaMask**: For handling transactions.
