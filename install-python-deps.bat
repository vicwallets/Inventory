@echo off
REM Installs pandas and openpyxl for build_quote_tool_v7.py.

echo Installing pandas and openpyxl...
echo.

py -m pip install --upgrade pip
py -m pip install pandas openpyxl

echo.
echo Verifying...
py -c "import pandas, openpyxl; print('pandas:', pandas.__version__, '| openpyxl:', openpyxl.__version__)"

echo.
pause
