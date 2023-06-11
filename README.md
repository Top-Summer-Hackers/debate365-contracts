# deBet365 

Betting is facing many problems : 
- Centralization of companies. 
- Lengthy withdrawal verification processes.
- Government bans 
- KYC 
- High fees to players 

deBet365 is solving those issues with a cutting-edge decentralized platfom with a new concept of Size Rebalacing which fixes the problem of Liquidity Providers. The Liquidatation risk is eliminated via rebalancing the Max Bet Size which shifts the balance of a pool in response to stakers transactions. 



## Proof of ` Size Rebalancing ` 

This rebalancing algorithm calculates the maximum stake that can be placed on a specific choice in a game. It considers the amount of money available in the reserves, subtracts the pending balances for that choice, and adjusts it based on a threshold value. It also takes into account the ratio of previous bets made on all choices. If the ratio exceeds a certain threshold (at least 1 percent), it allows for a larger maximum stake. This ensures that the available funds are distributed evenly among the different choices, promoting fairness and preventing a single choice from dominating the betting pool. It is like making sure that each option gets a fair share of the available money to maintain a balanced playing field.


#### Example :

If a user bets 100 usdc with a maximum betting size of 200 usdc on odd 2, this requires x usdc as collateral in the pool. 
If a user bets again 100 usdc a maximum betting size of 200 usdc on odd 2, our algorithm detects that it will require x + (n) amount as collateral 
in the pool. Since the collateral is only subject to staking by bettors, the max amount bet will shift and be less than the previous one. 


## Flow 

1. Collateral is deposited into a Game A to unlock the Game 
2. Off-chain ddds are retrieved with Chainlink and added to the on-chain algorithm. 
3. User A bets amout < maxAmount on the 1st odd fetched.
4. Algorithm runs 
5. Keepers trigger the keeper contract to rebalance the max amount to bet. 
6. The price feed is pulled from the oracle to inform rebalancing calculations.
7. The library calculates the rebalance


## Smart contracts 

- As a user you can open games with specific odds and token addresses. You can also update the odd on a specific game instance after providing liquidity. 

- Chainlink functions are used in the contract `Debet365FunctionsConsumer.sol` . This contract let the user execute requests and handling callback responses. 

- A player can bet on 3 choices. He can be a a maximum stake allowed based on the remaining reserves and odds. 

## Architecture 

<img width="909" alt="Screenshot 2023-06-10 at 6 50 48 AM" src="https://github.com/Top-Summer-Hackers/debate365-contracts/assets/75360886/175a2cba-c336-459b-baca-7a41a8bfe626">

## Chainlink Architecture 

<img width="878" alt="Screenshot 2023-06-11 at 9 22 41 PM" src="https://github.com/Top-Summer-Hackers/debate365-contracts/assets/75360886/c8c8841b-b088-4bd9-98c5-75b63064d3e4">


## Chainlink Functions 

Decentralized betting allow a more trustless user experience. In fact, users can check that the bookmaker have added a specific game with specific odds. This eliminates the control of odds and margin profits by bookies in the centralized betting system. By Adding Chainlink Functions, odds are retrieved on-chain via a server with an API endpoint which is retrieving odds from a provider (bookmaker). By implementing chainlink functions, we make sure to have odds on-chain. 

- The repository using Chainlink Functions with the server can be found here  : https://github.com/Top-Summer-Hackers/functions-365/tree/tutorials. To run it , follow the steps bellow : 


- ``` git clone https://github.com/Top-Summer-Hackers/functions-365.git ``` 
- ``` cd server ```
- ``` npm run build ```
- ``` npm start ```

The odds are then set via the API locally and send to [CheckOdds script](https://github.com/Top-Summer-Hackers/debate365-contracts/blob/main/script/CheckOdds.s.sol) where they are recorded on-chain after running on the [debate365-contracts](https://github.com/Top-Summer-Hackers/debate365-contracts) root folder : ``` forge script script/CheckOdds.s.sol --rpc-url polygonMumbai --broadcast ```                                                                                          ⏎


## Chainlink Functions and odds 

We have deployed our custom implementation of [FunctionsConsumer](https://mumbai.polygonscan.com/address/0xcfa537e30f0af3495330cf7c200f1f7b153be88a) 


- Game 1 : 1.5, 2.3, 3.3
- Game 2 : 1.23 6.69 9.09
- Game 3 : 2.03 3.88 3.0
- Game 4 : 1.86 3.94 4.45
- Game 5 : 2.87 2.92 2.53











