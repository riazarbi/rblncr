import requests
from datetime import datetime, timedelta
from dateutil import tz

def alpaca_connect(mode, api_key, api_secret):
    """
    Connect to an Alpaca backend.

    Use this function to specify which credentials to use to connect to Alpaca.

    Parameters:
    - mode (str): 'paper', 'live', or 'data'.
    - api_key (str): Corresponding Alpaca API key.
    - api_secret (str): Corresponding Alpaca API secret key.

    Returns:
    A dictionary that includes the backend, domain, and headers. This can be used
    to make authenticated requests to the Alpaca API.
    """
    backend = "alpaca"
    domain = alpaca_domain(mode)  # You need to define this function based on your requirements.
    headers = {
        'APCA-API-KEY-ID': api_key,
        'APCA-API-SECRET-KEY': api_secret
    }
    creds = {
        'backend': backend,
        'domain': domain,
        'headers': headers
    }
    return creds

def alpaca_domain(mode):
    """
    Determines the Alpaca domain based on the mode.

    Parameters:
    - mode (str): 'paper', 'live', or 'data'.

    Returns:
    The Alpaca domain URL as a string.
    """
    if mode == 'paper':
        return 'https://paper-api.alpaca.markets'
    elif mode == 'live':
        return 'https://api.alpaca.markets'
    elif mode == 'data':
        return 'https://data.alpaca.markets'
    else:
        raise ValueError("Mode must be 'paper', 'live', or 'data'.")


def alpaca_query(endpoint, alpaca_connection):
    """
    Query an endpoint using the Alpaca connection details.

    Parameters:
    - endpoint (str): The API endpoint to query.
    - alpaca_connection (dict): A dictionary containing the backend, domain, and headers for the connection.

    Returns:
    The content of the response if the status code is 200.

    Raises:
    - Exception: If the response status code is not 200.
    """
    url = f"{alpaca_connection['domain']}{endpoint}"
    headers = alpaca_connection['headers']
    # Add additional headers here if needed, for example:
    headers.update({"Content-Type": "application/octet-stream", "Accept": "application/json"})
    
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        return response.json()  # Assuming the response is JSON-formatted
    else:
        raise Exception(f"Error with status code: {response.status_code}")




def alpaca_account(alpaca_connection):
    """
    Fetch account information from Alpaca and return it as a pandas DataFrame.

    Parameters:
    - alpaca_connection (dict): A dictionary containing the backend, domain, and headers for the connection.

    Returns:
    A pandas DataFrame containing the account information.
    """
    result = alpaca_query("/v2/account", alpaca_connection)
    return result


def alpaca_clock(alpaca_connection):
    """
    Fetch the current market clock information from Alpaca and return it as a pandas DataFrame.

    Parameters:
    - alpaca_connection (dict): A dictionary containing the backend, domain, and headers for the connection.

    Returns:
    A pandas DataFrame containing the market clock information.
    """
    result = alpaca_query("/v2/clock", alpaca_connection)
    return result


def alpaca_assets(alpaca_connection):
    """
    Fetch information about active US equity assets from Alpaca.

    Parameters:
    - alpaca_connection (dict): A dictionary containing the backend, domain, and headers for the connection.

    Returns:
    The result of the query as a dictionary or list of dictionaries.
    """
    endpoint = "/v2/assets?asset_class=us_equity&status=active"
    result = alpaca_query(endpoint, alpaca_connection)
    return result


def alpaca_get_orders(alpaca_connection, status="open"):
    """
    Fetch orders with a specific status from Alpaca.

    Parameters:
    - alpaca_connection (dict): A dictionary containing the backend, domain, and headers for the connection.
    - status (str): The status of the orders to fetch. Defaults to "open".

    Returns:
    The result of the query as a list of dictionaries, each representing an order.
    """
    endpoint = f"/v2/orders?status={status}"
    result = alpaca_query(endpoint, alpaca_connection)
    return result


def alpaca_positions(alpaca_connection):
    """
    Fetch current open positions from Alpaca.

    Parameters:
    - alpaca_connection (dict): A dictionary containing the backend, domain, and headers for the connection.

    Returns:
    The result of the query, typically a list of positions.
    """
    endpoint = "/v2/positions"
    result = alpaca_query(endpoint, alpaca_connection)
    return result



def alpaca_daily_bars(symbol, days, alpaca_connection):
    """
    Fetch daily bar data for a given symbol from Alpaca.

    Parameters:
    - symbol (str): The stock symbol to fetch daily bars for.
    - days (int): The number of days to fetch data for.
    - alpaca_connection (dict): A dictionary containing the backend, domain, and headers for the connection.

    Returns:
    A pandas DataFrame containing the daily bars data.
    """
    # Calculate the start date
    utc_zone = tz.gettz('UTC')
    start = datetime.now(utc_zone) - timedelta(days=days)
    start_str = start.strftime("%Y-%m-%dT%H:%M:%S")

    # Construct the endpoint URL
    endpoint = f"/v2/stocks/{symbol}/bars?timeframe=1day&start={start_str}Z"
    
    # Query the Alpaca API
    result = alpaca_query(endpoint, alpaca_connection)
    
    # Convert the result to a pandas DataFrame
    if 'bars' in result:
        return result['bars']
    else:
        return None



def alpaca_minute_bars(symbol, minutes, alpaca_connection):
    """
    Fetch minute bar data for a given symbol from Alpaca.

    Parameters:
    - symbol (str): The stock symbol to fetch minute bars for.
    - minutes (int): The number of minutes to fetch data for.
    - alpaca_connection (dict): A dictionary containing the backend, domain, and headers for the connection.

    Returns:
    The result of the query.
    """
    utc_zone = tz.gettz('UTC')
    start = datetime.now(utc_zone) - timedelta(minutes=minutes)
    start_str = start.strftime("%Y-%m-%dT%H:%M:%S")

    endpoint = f"/v2/stocks/{symbol}/bars?timeframe=1min&start={start_str}Z"
    result = alpaca_query(endpoint, alpaca_connection)
    return result
