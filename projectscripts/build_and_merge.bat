@echo off
setlocal enabledelayedexpansion

if not exist "variables.bat" (
    copy .variables.structure.bat variables.bat
    echo variables.bat created. Please fill in all of the empty variables, then rerun this script.
    pause
	exit
)
call variables.bat

set empty_variables=true
if not "%MODLOADER_PROJECT_PATH%"=="" if not "%UNDERTALEMODCLI_PATH%"=="" if not "%NNF_PATH%"=="" if not "%GAMEMAKER_CACHE_PATH%"=="" if not "%LICENSE_FILE_PATH%"=="" (
	set empty_variables=false
)
if %empty_variables%==true (
	echo Some variables are empty. Please fill in all of the variables.
	pause
	exit
)

cd "%MODLOADER_PROJECT_PATH%\projectscripts"


if not exist "%NNF_PATH%\clean_data.win" (
	echo First run detected. Please make sure the data.win in "%NNF_PATH%" is not modified.

	set /P "USER_ANSWER=Continue? (y/n) "
	
	if /i "!USER_ANSWER!"=="Y" (
		echo I believe you... Copying clean_data.win
		copy "%NNF_PATH%\data.win" "%NNF_PATH%\clean_data.win"
	) else (
		exit
	)
)

set IGOR_PATH=%GAMEMAKER_CACHE_PATH%\runtimes\runtime-2023.8.2.152\bin\igor\windows\x64\Igor.exe
set RUNTIME_PATH=%GAMEMAKER_CACHE_PATH%\runtimes\runtime-2023.8.2.152

if exist "data.win" (
	echo Removing old data.win
	del "data.win"
)

echo -------------------------------
echo Building NF's GameMaker project
echo -------------------------------

"%IGOR_PATH%" ^
/lf="%LICENSE_FILE_PATH%" ^
/project="%MODLOADER_PROJECT_PATH%\nubbys-forgery.yyp" ^
/rp="%RUNTIME_PATH%" ^
/tf="nubbys-forgery.zip" ^
-- Windows PackageZip

if not exist ".\output\nubbys-forgery\data.win" (
	echo Something failed. Could not find data.win.
	pause
	exit
)
echo Building finished.
copy .\output\nubbys-forgery\data.win .\data.win

echo Removing output folder and zip
rmdir /s /q ".\output" 
if exist ".\nubbys-forgery.zip" (
	del ".\nubbys-forgery.zip"
)

echo -----------------------------------
echo Merging into Nubby's Number Factory
echo -----------------------------------

"%UNDERTALEMODCLI_PATH%" load "%NNF_PATH%\clean_data.win" --scripts ".\merger.csx" --output "%NNF_PATH%\data.win"

echo All done!
