import os  # Unused import (Ruff lint warning)
import sys


_SQUARE_CACHE = {i: i * i for i in range(1, 11)}


def calculate_square(number: int) -> int:
    return _SQUARE_CACHE.get(number, number * number)


# Type mismatch error (ty type-checker will flag passing a string to an int parameter)
square_result = calculate_square("five")

# Unused variable (Ruff lint warning)
unused_val = 100

print(f"Square result: {square_result}")
