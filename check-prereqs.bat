@echo off
REM Checks what's installed for the auto-deploy pipeline.

echo === Git ===
where git 2>nul
git --version 2>nul
echo.

echo === Python ===
where python 2>nul
python --version 2>nul
where py 2>nul
py --version 2>nul
echo.

echo === Python packages (for build_quote_tool_v7.py) ===
python -c "import pandas; print('pandas:', pandas.__version__)" 2>nul || echo pandas NOT installed
python -c "import openpyxl; print('openpyxl:', openpyxl.__version__)" 2>nul || echo openpyxl NOT installed
echo.

echo === GitHub Desktop credentials ===
where git-credential-manager 2>nul
where git-credential-manager-core 2>nul
echo.

echo Done. Tell Claude what this output says.
pause
