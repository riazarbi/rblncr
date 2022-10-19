# rblncr

Declarative portfolio management with R. 

## Aspiration

It should be possible to rebalance your equity portfolio by changing the contents of a file on your computer or in a github repo.

## WIP Notice

This repo is a work in progress. The rationale for the proect is covered in this [blog post](https://riazarbi.github.io/quant/portfoli-model-spec/). Everything in this repo (including this README) is likely to change dramatically as I code through the problem. 

## Basic elements

- Portfolio Model Specification  
- tooling to retrieve current holdings from broker  
- trade generation engine to compute required trades to get the current holdings to the model specification  
- trade submission tooling to actually submit trades to broker  

## Dev Steps

[ ] Develop portfolio model spec and tooling  
[ ] Select initial broker to develop against  
[ ] Write functions to obtain portfolio holdings from broker  
[ ] Build order generator  
[ ] Write functions to submit orders to broker  
[ ] Write tests  
[ ] Write documentation  
[ ] Jump through RCMDCHECK hoops  
[ ] Create a github action to periodically execute the code necessary to rebalance the portfolio  

## Concepts

`backend` : trading backend that you'll submit orders to  
`universe` : the universe of assets, along with id, symbol, exposure constraint categories  
`target_weights` : target percentage weights of each asset in the universe (perhaps a column in universe file?)  
`volume_limit_daily_pct`  
`soft_rebalancing_constraint`: don't trade if this close to perfect balance  


## Objects

- portfolio model  
- trading account  
- order  
- order array  

# Records
- trades  
- order statuses  

## Alpaca Rebalancing API


# Functions

- validate_portfolio_model  

- create_portfolio_model  
- update_portfolio_model  
- save_portfolio_model  


