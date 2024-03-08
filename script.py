from rebalancer.alpaca import alpaca_connect, alpaca_daily_bars, alpaca_minute_bars, alpaca_account, alpaca_clock, alpaca_assets, alpaca_get_orders, alpaca_positions
import os
import pprint




api_key = os.getenv('ALPACA_PAPER_KEY')
api_secret = os.getenv('ALPACA_PAPER_SECRET')

client = alpaca_connect('paper', api_key, api_secret) 
data_client = alpaca_connect('data', api_key, api_secret) 

type(alpaca_account(client))

clock = alpaca_clock(client)
assets = alpaca_assets(client)
positions = alpaca_positions(client)
orders = alpaca_get_orders(client)

daily_bars = alpaca_daily_bars('AAPL', 5, data_client)

minute_bars = alpaca_minute_bars('BRK', 30, data_client)

pprint.pprint(daily_bars)

