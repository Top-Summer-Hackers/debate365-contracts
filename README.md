# deBet365 

deBet365 is a decentralized betting platform focusing on rebalancing liquidity to maintaining it's viability. 
deBet365 eliminates liquidation risk via staking rebalancing max bet size which shifts the balance 
of a pool in response to stakers betting on a certain odd. 
Our protocol offer both betting back & lay better odds by querying the off-chain odds via Chainlink 
Functions and updating odds on-chain which avoids odds manipulation by centralized bookmakers. 

## Our Algorithmic rebalancing 

deBet356 algorithm automatically rebalance maximum bet size to prevent under-collateralisation. 
It also checks that odds stays in a valid range to avoid arbitrage situations by using Chainlink Functions. 

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




