# These variables will be used by build_and_merge.sh

# Do not include a `/` at the end of any of the variables, including when filling in folder paths.

# The path to the modloader's project folder (where the .yyp is)
MODLOADER_PROJECT_PATH=""

# Path to the UndertaleModCli executable
UNDERTALEMODCLI_PATH=""

# Path to the game's directory (The folder Steam opens when selecting Manage>Browse Local Files)
# Could possibly be /home/USER/.local/share/Steam/steamapps/common/Nubby's Number Factory
NNF_PATH=""

# Likely is /home/USER/.local/share/GameMakerStudio2/Cache
GAMEMAKER_CACHE_PATH=""

# Likely is /home/USER/.config/GameMakerStudio2/user_somenumbers
USER_DIRECTORY_PATH=""


# Should also run the game?
# If yes, set the variable below to "steam steam://rungameid/3191030/"
GAME_RUN_COMMAND=""

# Should run Simple Logging Interface Program (slip) (https://github.com/Skirlez/slip) along with the game?
# If yes, set the path to its executable here.
# Logging wiki page: https://github.com/Skirlez/nubbys-forgery/wiki/Logging
SLIP_PATH=""
