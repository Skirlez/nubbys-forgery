:: These variables will be used by build_and_merge.bat
:: Do not include a `\` at the end of any of the variables, including when filling in folder paths.
:: Make sure to include quotation marks around both the variable name and the value, for example: 
:: set "VARIABLE=VALUE"

:: The path to the modloader's project folder (where the .yyp is)
set "MODLOADER_PROJECT_PATH="

:: Path to UndertaleModCli.exe
set "UNDERTALEMODCLI_PATH="

:: Path to the game's directory (The folder Steam opens when selecting Manage>Browse Local Files)
:: Likely is C:\Program Files (x86)\Steam\steamapps\common\Nubby's Number Factory
set "NNF_PATH="

:: Likely is C:\ProgramData\GameMakerStudio2\Cache
set "GAMEMAKER_CACHE_PATH="

:: Likely is %appdata%\GameMakerStudio2\user_somenumbers\licence.plist (Watch the British spelling!)
:: If you get a Permission Error : Unable to obtain permission to execute message, you should try generating your own license file
:: https://manual.gamemaker.io/monthly/en/Settings/Building_via_Command_Line.htm (Access Key section.)
:: Once you have the new license file, fill in the path to it here. I'd recommend placing it in projectscripts, as git will ignore it there.
set "LICENSE_FILE_PATH="




