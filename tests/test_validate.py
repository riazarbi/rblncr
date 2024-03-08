from rebalancer.validate import validate_clock, validate_assets, validate_positions, validate_orders, validate_bars
import pytest


def test_valid_dict():
    valid_data = {
        'timestamp': '2024-03-08T01:38:37.965880788-05:00',
        'is_open': False,
        'next_open': '2024-03-08T09:30:00-05:00',
        'next_close': '2024-03-08T16:00:00-05:00'
    }
    assert validate_clock(valid_data) == True

def test_missing_keys():
    with pytest.raises(ValueError):
        validate_clock({'timestamp': '2024-03-08T01:38:37.965880788-05:00', 'is_open': False})

def test_invalid_timestamp():
    invalid_data = {
        'timestamp': 'string',  # Incorrect format
        'is_open': False,
        'next_open': '2024-03-08T09:30:00-05:00',
        'next_close': '2024-03-08T16:00:00-05:00'
    }
    with pytest.raises(ValueError):
        validate_clock(invalid_data)

def test_invalid_is_open_type():
    invalid_data = {
        'timestamp': '2024-03-08T01:38:37.965880788-05:00',
        'is_open': 'False',  # Incorrect type
        'next_open': '2024-03-08T09:30:00-05:00',
        'next_close': '2024-03-08T16:00:00-05:00'
    }
    with pytest.raises(ValueError):
        validate_clock(invalid_data)


def test_validate_assets():
    valid_assets = [
        {
            'class': 'us_equity',
            'exchange': 'NASDAQ',
            'symbol': 'AAPL',
            'name': 'Apple Inc.',
            'status': 'active'
        },
        {
            'class': 'us_equity',
            'exchange': 'NYSE',
            'symbol': 'MSFT',
            'name': 'Microsoft Corporation',
            'status': 'active'
        }
    ]

    invalid_assets = [
        {'class': 'us_equity', 'exchange': 'NASDAQ', 'symbol': 'AAPL'},  # Missing 'name' and 'status'
        {'class': 'us_equity', 'exchange': 'NYSE', 'name': 'Microsoft Corporation', 'status': 'active'},  # Missing 'symbol'
        'This is not a dictionary',  # Not a dictionary
        123  # Not a list
    ]

    assert validate_assets(valid_assets) == True
    
    for asset in invalid_assets:
        assert validate_assets(asset) == False



def test_validate_positions_valid():
    positions = [
        {
            'symbol': 'AAPL',
            'exchange': 'NASDAQ',
            'qty': 100,
            'current_price': 150.50
        },
        {
            'symbol': 'MSFT',
            'exchange': 'NYSE',
            'qty': 200,
            'current_price': 250.75
        }
    ]
    assert validate_positions(positions) == True

def test_validate_positions_invalid_list():
    positions = 'This is not a list'
    assert validate_positions(positions) == False

def test_validate_positions_invalid_dicts():
    positions = [
        {'symbol': 'AAPL', 'exchange': 'NASDAQ', 'qty': 100},  # Missing 'current_price'
        {'symbol': 'MSFT', 'exchange': 'NYSE', 'current_price': 250.75},  # Missing 'qty'
        {'exchange': 'NASDAQ', 'qty': 100, 'current_price': 150.50},  # Missing 'symbol'
        {'symbol': 'AAPL', 'exchange': 'NASDAQ', 'qty': 100, 'current_price': '150.50'},  # 'current_price' not a float
        {'symbol': 'AAPL', 'exchange': 'NASDAQ', 'qty': '100', 'current_price': 150.50},  # 'qty' not an int
    ]
    assert validate_positions(positions) == False


def test_validate_orders_valid():
    data = [
        {
            'submitted_at': '2024-03-08T07:11:50.376794381Z',
            'id': 'bb1dd7ef-ff83-4478-ae28-5711e4f4f044',
            'status': 'accepted',
            'side': 'buy',
            'qty': 100,
            'limit_price': 108.0,
            'filled_qty': 0,
            'filled_avg_price': None
        }
    ]
    assert validate_orders(data) == True

def test_validate_orders_invalid_list():
    data = 'This is not a list'
    assert validate_orders(data) == False

def test_validate_orders_invalid_dicts():
    data = [
        {'submitted_at': '2024-03-08T07:11:50.376794381Z', 'id': 'bb1dd7ef-ff83-4478-ae28-5711e4f4f044'},  # Missing keys
        {'submitted_at': '2024-03-08T07:11:50.376794381Z', 'id': 'bb1dd7ef-ff83-4478-ae28-5711e4f4f044', 'status': 'accepted', 'side': 'buy', 'qty': '100', 'limit_price': 108.0, 'filled_qty': 0, 'filled_avg_price': None},  # 'qty' not an int
        {'submitted_at': '2024-03-08T07:11:50.376794381Z', 'id': 'bb1dd7ef-ff83-4478-ae28-5711e4f4f044', 'status': 'accepted', 'side': 'buy', 'qty': 100, 'limit_price': '108.0', 'filled_qty': 0, 'filled_avg_price': None}  # 'limit_price' not a float
    ]
    assert validate_orders(data) == False



def test_validate_bars_valid():
    data = [
        {'t': '2024-03-04T05:00:00Z', 'o': 176.15, 'h': 176.9, 'l': 173.79, 'c': 175.1, 'v': 81510101, 'n': 1167167, 'vw': 174.893781},
        {'t': '2024-03-05T05:00:00Z', 'o': 170.76, 'h': 172.04, 'l': 169.62, 'c': 170.12, 'v': 95432355, 'n': 1108821, 'vw': 170.323381},
        {'t': '2024-03-06T05:00:00Z', 'o': 171.06, 'h': 171.24, 'l': 168.68, 'c': 169.12, 'v': 68509887, 'n': 891946, 'vw': 169.551708},
        {'t': '2024-03-07T05:00:00Z', 'o': 169.15, 'h': 170.73, 'l': 168.49, 'c': 169, 'v': 71765379, 'n': 825411, 'vw': 169.361854}
    ]
    assert validate_bars(data) == True

def test_validate_daily_bars_invalid_list():
    data = 'This is not a list'
    assert validate_bars(data) == False

def test_validate_daily_bars_invalid_dicts():
    data = [
        {'t': '2024-03-04T05:00:00Z', 'o': 176.15, 'h': 176.9, 'l': 173.79, 'c': 175.1, 'v': 81510101, 'n': 1167167},  # Missing 'vw'
        {'t': '2024-03-05T05:00:00Z', 'o': 170.76, 'h': 172.04, 'l': 169.62, 'c': '170.12', 'v': 95432355, 'n': 1108821, 'vw': 170.323381},  # 'c' not a float
        {'t': '2024-03-06T05:00:00Z', 'o': 171.06, 'h': 171.24, 'l': 168.68, 'c': 169.12, 'v': 68509887, 'n': '891946', 'vw': 169.551708},  # 'n' not an int
        {'t': '2024-03-07T05:00:00Z', 'o': 169.15, 'h': 170.73, 'l': 168.49, 'c': 169, 'v': 71765379, 'vw': 169.361854}  # Missing 'n'
    ]
    assert validate_bars(data) == False

def test_validate_daily_bars_none():
    assert validate_bars(None) == True
