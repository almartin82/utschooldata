"""
Tests for pyutschooldata Python wrapper.

Minimal smoke tests - the actual data logic is tested by R testthat.
These just verify the Python wrapper imports and exposes expected functions.
"""

import pytest


def test_import_package():
    """Package imports successfully."""
    import pyutschooldata
    assert pyutschooldata is not None


def test_has_fetch_enr():
    """fetch_enr function is available."""
    import pyutschooldata
    assert hasattr(pyutschooldata, 'fetch_enr')
    assert callable(pyutschooldata.fetch_enr)


def test_has_get_available_years():
    """get_available_years function is available."""
    import pyutschooldata
    assert hasattr(pyutschooldata, 'get_available_years')
    assert callable(pyutschooldata.get_available_years)


def test_has_version():
    """Package has a version string."""
    import pyutschooldata
    assert hasattr(pyutschooldata, '__version__')
    assert isinstance(pyutschooldata.__version__, str)
