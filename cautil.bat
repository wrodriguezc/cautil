@echo off

SETLOCAL EnableExtensions
for /f "delims=" %%a in ('reg query HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\CertSvc\Configuration\') do @set CA_NAME=%%a
if '%CA_NAME%'=='ERROR: The system was unable to find the specified registry key or value.' goto :error

:main
cls
echo.
echo CA utility v1.0
echo William Rodriguez
echo Universidad Cenfotec - 2017
echo.
echo Main menu
echo ---------------------------------- 
echo.
echo 1. Manage CA
echo 2. Request certificate
echo 3. Quit
set /p choice=Select option then press [Enter]
if '%choice%'=='1' goto :manage
if '%choice%'=='2' goto :request
if '%choice%'=='3' goto :quit
goto main

:manage
cls
echo.
echo Manage CA
echo ---------------------------------- 
echo.
echo 1. Display CA info
echo 2. Change Validity Period Units
echo 3. Return
set /p choice=Select option then press [Enter]
if '%choice%'=='1' goto :info
if '%choice%'=='2' goto :change
if '%choice%'=='3' goto :main
goto manage

:info
cls
echo.
echo CA Information
echo ---------------------------------- 
echo.
for /f "usebackq tokens=1-3" %%a in (`reg query "%CA_NAME%" /v CAServerName 2^>nul`) do @set CAServerName=%%c
for /f "usebackq tokens=1-3" %%a in (`reg query "%CA_NAME%" /v CommonName 2^>nul`) do @set CommonName=%%c
for /f "usebackq tokens=1-3" %%a in (`reg query "%CA_NAME%" /v ValidityPeriod 2^>nul`) do @set ValidityPeriod=%%c
for /f "usebackq tokens=1-3" %%a in (`reg query "%CA_NAME%" /v ValidityPeriodUnits 2^>nul`) do @set ValidityPeriodUnits=%%c
echo CAServerName:         %CAServerName%
echo CommonName:           %CommonName%
echo ValidityPeriod:       %ValidityPeriod%
echo ValidityPeriodUnits:  %ValidityPeriodUnits%
echo.
pause
goto :manage

:change
cls
echo.
echo Change CA Validity Period Units
echo ---------------------------------- 
echo.
set /p period=Enter the number of years then press [Enter]
if '%period%'=='' goto :change
if '%period%'=='0' goto :change
reg add "%CA_NAME%" /v ValidityPeriodUnits /d %period% /f
echo ValidityPeriodUnits set to %period%
pause
goto :manage

:request
cls
echo.
echo Create Certificate Request
echo ---------------------------------- 
echo.
:step1
echo Certificate type 
echo 1. Server Authentication Certificate
echo 2. Client Authentication Certificate
set /p certtypeoption=Select certificate type to create then press [Enter]  (Default .1)
if '%certtypeoption%'=='1' set certype=request
if '%certtypeoption%'=='2' set certype=request
echo.
:step2
set /p cn=Type CN then press [Enter] (Required)
if '%cn%'=='' goto :step2
echo.
:step3
set /p keylength=Type key size then press [Enter] (Default 2048)
if '%keylength%'=='' set keylength=2048
:step4
echo.
set /p name=Type the name of the request then press [Enter] (Default 'request.req')
if '%name%'=='' set name=request
(
    echo [Version] 
    echo Signature="$Windows NT$"
    echo.
    echo [NewRequest] 
    echo Subject = "CN=%cn%"
    echo KeyLength = %keylength%
) > %name%.inf
certreq -new "%name%.inf" "%name%.req"
echo Request "%name%.req" was created.
pause
goto :main

:error
echo Can't find CA registry keys. Please configure a CA first.
:quit