from dateutil.parser import parse
from dateutil.tz import tzoffset

def validate_clock(data):
    """
    Validates the structure and data types of the given dictionary.

    Parameters:
    - data (dict): The dictionary to validate.

    Returns:
    - bool: True if valid, raises ValueError otherwise.
    """
    
    if not isinstance(data, dict):
        return False
    
    required_keys = ["timestamp", "is_open", "next_open", "next_close"]
    
    if not all(key in data for key in required_keys):
        raise ValueError("Missing one or more required keys")

    try:
        # Using dateutil's parse for more flexible datetime parsing
        parse(data['timestamp'])
        parse(data['next_open'])
        parse(data['next_close'])
    except ValueError:
        raise ValueError("Invalid datetime format")

    # Validate is_open is a boolean
    if not isinstance(data['is_open'], bool):
        raise ValueError("is_open must be a boolean")

    return True


def validate_assets(asset_list):
    if not isinstance(asset_list, list):
        return False
    
    required_keys = ['class', 'exchange', 'symbol', 'name', 'status']
    required_types = {
        'class': str,
        'exchange': str,
        'symbol': str,
        'name': str,
        'status': str
    }
    
    for asset in asset_list:
        if not isinstance(asset, dict):
            return False
        for key in required_keys:
            if key not in asset:
                return False
            if not isinstance(asset[key], required_types[key]):
                return False
    return True


def validate_positions(positions):
    # Check if positions is a list
    if not isinstance(positions, list):
        return False
    
    # Define the required keys and their expected data types
    required_keys = {
        'symbol': str,
        'exchange': str,
        'qty': int,
        'current_price': float
    }
    
    # Iterate over each dictionary in the list
    for position in positions:
        # Check if each position is a dictionary
        if not isinstance(position, dict):
            return False
        # Check if all required keys are present in the position dictionary
        for key, data_type in required_keys.items():
            if key not in position:
                return False
            # Check if the value is of the expected data type
            if not isinstance(position[key], data_type):
                return False
    return True


def validate_orders(data):
    required_keys = ['submitted_at', 'id', 'status', 'side', 'qty', 'limit_price', 'filled_qty', 'filled_avg_price']
    required_types = {
        'submitted_at': str,
        'id': str,
        'status': str,
        'side': str,
        'qty': int,
        'limit_price': float,
        'filled_qty': int,
        'filled_avg_price': (float, type(None))
    }
    
    if not isinstance(data, list):
        return False
    
    if len(data) == 0:  # Accepts an empty list
        return True
    
    for item in data:
        if not isinstance(item, dict):
            return False
        for key in required_keys:
            if key not in item:
                return False
            if not isinstance(item[key], required_types[key]):
                return False
    
    return True


def validate_bars(data):
    if data is None:
        return True
    
    required_keys = ['t', 'o', 'h', 'l', 'c', 'v', 'n', 'vw']
    required_types = {
        't': str,
        'o': (float, int),
        'h': (float, int),
        'l': (float, int),
        'c': (float, int),
        'v': int,
        'n': int,
        'vw': (float, int)
    }
    
    if not isinstance(data, list):
        print("Validation failed: Input is not a list")
        return False
    
    for item in data:
        if not isinstance(item, dict):
            print("Validation failed: Item is not a dictionary")
            return False
        for key in required_keys:
            if key not in item:
                print(f"Validation failed: Key '{key}' missing in dictionary: {item}")
                return False
            if not isinstance(item[key], required_types[key]):
                print(f"Validation failed: Invalid data type for key '{key}' in dictionary: {item}")
                return False
    
    return True
