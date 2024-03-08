# test_alpaca.py

from rebalancer.alpaca import alpaca_connect, alpaca_domain, alpaca_query, alpaca_daily_bars, alpaca_minute_bars
from unittest.mock import patch
import pytest
import pandas as pd
from unittest.mock import patch
from datetime import datetime, timedelta
from dateutil import tz



def test_alpaca_domain():
    assert alpaca_domain('paper') == 'https://paper-api.alpaca.markets'
    assert alpaca_domain('live') == 'https://api.alpaca.markets'
    assert alpaca_domain('data') == 'https://data.alpaca.markets'
    try:
        alpaca_domain('invalid')
        assert False, "alpaca_domain did not raise ValueError on invalid input"
    except ValueError:
        assert True

def test_alpaca_connect():
    mode = 'paper'
    api_key = 'test_key'
    api_secret = 'test_secret'
    creds = alpaca_connect(mode, api_key, api_secret)

    assert creds['backend'] == 'alpaca'
    assert creds['domain'] == 'https://paper-api.alpaca.markets'
    assert creds['headers']['APCA-API-KEY-ID'] == api_key
    assert creds['headers']['APCA-API-SECRET-KEY'] == api_secret


@patch('rebalancer.alpaca.requests.get')  # Adjust the patch target to match where requests.get is used
def test_alpaca_query_success(mock_get):
    # Mocking a successful response
    mock_get.return_value.status_code = 200
    mock_get.return_value.json.return_value = {"key": "value"}

    alpaca_connection = {
        'domain': 'https://paper-api.alpaca.markets',
        'headers': {
            'APCA-API-KEY-ID': 'test_key',
            'APCA-API-SECRET-KEY': 'test_secret'
        }
    }
    endpoint = '/v2/account'
    response = alpaca_query(endpoint, alpaca_connection)

    assert response == {"key": "value"}
    mock_get.assert_called_once_with(f'https://paper-api.alpaca.markets/v2/account', headers=alpaca_connection['headers'])

@patch('rebalancer.alpaca.requests.get')  # Adjust the patch target to match where requests.get is used
def test_alpaca_query_failure(mock_get):
    # Mocking an unsuccessful response
    mock_get.return_value.status_code = 404

    alpaca_connection = {
        'domain': 'https://paper-api.alpaca.markets',
        'headers': {
            'APCA-API-KEY-ID': 'test_key',
            'APCA-API-SECRET-KEY': 'test_secret'
        }
    }
    endpoint = '/v2/nonexistent'

    with pytest.raises(Exception) as excinfo:
        alpaca_query(endpoint, alpaca_connection)
    assert "Error with status code: 404" in str(excinfo.value)



@patch('rebalancer.alpaca.alpaca_query')  # Correct this to the path of your alpaca_query function
def test_alpaca_daily_bars(mock_alpaca_query):
    # Mock response from alpaca_query
    mock_response = {
        'bars': [
            {'t': '2021-01-01T00:00:00Z', 'o': 100, 'h': 110, 'l': 95, 'c': 105, 'v': 10000},
            {'t': '2021-01-02T00:00:00Z', 'o': 105, 'h': 115, 'l': 100, 'c': 110, 'v': 10500}
        ]
    }
    mock_alpaca_query.return_value = mock_response

    alpaca_connection = {
        'backend': 'alpaca',
        'domain': 'https://paper-api.alpaca.markets',
        'headers': {
            'APCA-API-KEY-ID': 'test_key',
            'APCA-API-SECRET-KEY': 'test_secret'
        }
    }
    symbol = "AAPL"
    days = 5
    
    # Call the function under test
    bars = alpaca_daily_bars(symbol, days, alpaca_connection)

    # Assert the response is as expected
    assert bars == mock_response['bars'], "The function should return the mock 'bars' data"

    # Check if alpaca_query was called with the correct parameters
    utc_zone = tz.gettz('UTC')
    start = datetime.now(utc_zone) - timedelta(days=days)
    start_str = start.strftime("%Y-%m-%dT%H:%M:%S")
    expected_endpoint = f"/v2/stocks/{symbol}/bars?timeframe=1day&start={start_str}Z"
    mock_alpaca_query.assert_called_once_with(expected_endpoint, alpaca_connection)



@patch('rebalancer.alpaca.alpaca_query')  # Make sure to correctly reference your module's structure
def test_alpaca_minute_bars(mock_alpaca_query):
    # Setup mock response
    mock_response = {
        'bars': [
            {'t': '2021-01-01T12:00:00Z', 'o': 100, 'c': 105, 'v': 1200}
        ]
        }
    mock_alpaca_query.return_value = mock_response

    # Expected values
    symbol = 'AAPL'
    minutes = 60
    alpaca_connection = {'domain': 'https://paper-api.alpaca.markets', 'headers': {'APCA-API-KEY-ID': 'test_key', 'APCA-API-SECRET-KEY': 'test_secret'}}

    # Call the function
    result = alpaca_minute_bars(symbol, minutes, alpaca_connection)

    # Assertions
    assert result == mock_response['bars'], "The function should return the mock response data"
    
    # Verify the correct API endpoint was called
    utc_zone = tz.gettz('UTC')
    start = datetime.now(utc_zone) - timedelta(minutes=minutes)
    start_str = start.strftime("%Y-%m-%dT%H:%M:%S")
    expected_endpoint = f"/v2/stocks/{symbol}/bars?timeframe=1min&start={start_str}Z"
    mock_alpaca_query.assert_called_once_with(expected_endpoint, alpaca_connection)
