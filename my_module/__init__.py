import sys
import os

from my_module.structures import UserData, simple_change, simple_get_set_values, simple_get_values, simple_import_values
# from my_module.my_func import simple_change, simple_get_set_values, simple_get_values, simple_import_values
sys.path.append(os.getcwd() + '/my_module')

__all__ = ["UserData", "simple_change", "simple_get_set_values", "simple_get_values", "simple_import_values"]
