#!/bin/bash

# Shell script to build Nubby's Forgery's GameMaker project and merge it with Nubby's Number Factory

if [ ! -f "variables.sh" ]; then
  cp .variables.structure.sh variables.sh
  echo "variables.sh created. Please fill in all of the empty variables, then rerun this script."
  exit 1
fi

echo "Reading variables.sh"
source variables.sh

if [ -z "$GAMEMAKER_CACHE_PATH" ] || [ -z "$USER_DIRECTORY_PATH" ] || [ -z "$MODLOADER_PROJECT_PATH" ] || [ -z "$UNDERTALEMODCLI_PATH" ] || [ -z "$NNF_PATH" ]; then
    echo "Could not build NF:"
    echo "Some variables are empty. Please fill in all of the variables."
    exit 1
fi

if [ ! -x "$UNDERTALEMODCLI_PATH" ]; then
  echo ""
  echo "UndertaleModCli not set as executable. Please run"
  echo "chmod +x path/to/UndertaleModCli"
  read -p "Try running the command? (y/n): " answer
  if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
      chmod +x "$UNDERTALEMODCLI_PATH";
      if [ ! -x "$UNDERTALEMODCLI_PATH" ]; then
         echo "Could not build NF:"
         echo "Couldn't set UndertaleModCli as an executable. Do it yourself."
      else
        echo "Success. Proceeding with script."
      fi
  else
      exit 1
  fi
fi

cd "$MODLOADER_PROJECT_PATH/projectscripts"

if [ ! -f "$NNF_PATH/clean_data.win" ]; then
  echo "First run detected. Please make sure the data.win in $NNF_PATH is not modified."
  read -p "Continue? (y/n): " answer
  if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
      echo "I believe you... Copying clean_data.win"
      cp "$NNF_PATH/data.win" "$NNF_PATH/clean_data.win"
  else
      exit 1
  fi
fi


IGOR_PATH="$GAMEMAKER_CACHE_PATH/runtimes/runtime-2023.4.0.113/bin/igor/linux/x64/Igor"
RUNTIME_PATH="$GAMEMAKER_CACHE_PATH/runtimes/runtime-2023.4.0.113"

if [ -f "./data.win" ]; then
  echo "Removing old data.win"
  rm ./data.win
fi

echo "-------------------------------"
echo "Building NF's GameMaker project"
echo "-------------------------------"


$IGOR_PATH \
    -j=8 \
    --user="$USER_DIRECTORY_PATH" \
    --project="$MODLOADER_PROJECT_PATH/nubbys-forgery.yyp" \
    --runtimePath="$RUNTIME_PATH" \
    --tf="nubbys-forgery.zip" \
    --temp="./temp/" \
    -- Linux Package

cp ./output/nubbys-forgery/package/assets/game.unx ./data.win
if [ $? -eq 0 ]; then
    echo "Building finished."
else
    echo "Could not build NF:"
    echo "Something failed. Could not find game.unx."
    exit 1
fi

if [ -d "./output" ]; then
  echo "Removing output folder and zip"
  rm -rf ./output
  rm nubbys-forgery.zip
fi



echo "-----------------------------------"
echo "Merging into Nubby's Number Factory"
echo "-----------------------------------"

# https://github.com/UnderminersTeam/UndertaleModTool/pull/2063
rm "$NNF_PATH/data.win"

$UNDERTALEMODCLI_PATH load "$NNF_PATH/clean_data.win" --scripts "./merger.csx" --output "$NNF_PATH/data.win"

echo "All done!"