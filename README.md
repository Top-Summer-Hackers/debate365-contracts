# debate365-contracts

deBet365 eliminates liquidation risk via staking rebalancing max bet size which shifts the balance 
of a pool in response to stakers betting on a certain odd. 

Our protocol offer both betting back & lay better odds by querying the off-chain odds via Chainlink 
Functions and updating odds on-chain which avoids odds manipulation by centralized bookmakers. 

## Our Algorithmic rebalancing 

deBet356 algorithm automatically rebalance maximum bet size to prevent under-collateralisation. 
It also checks that odds stays in a valid range to avoid arbitrage situations by using Chainlink Keepers and 
Chainlink Functions. 

- Dymanic rebalancing guarantee users to get paid if they win. It also let our protocol be a healthy and stable 
protocol. 

Example :

If a user bets 100 usdc with a maximum betting size of 200 usdc on odd 2, this requires x usdc as collateral in the pool. 
If a user bets again 100 usdc a maximum betting size of 200 usdc on odd 2, our algorithm detects that it will require x + (n) amount as collateral 
in the pool. Since the collateral is only subject to staking by bettors, the max amount bet will shift and be less than the previous one. 



