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
  echo "UndertaleModCli is not set as executable. Please run"
  echo "chmod +x path/to/UndertaleModCli"
  read -p "Try running the command? (y/n): " answer
  if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
      chmod +x "$UNDERTALEMODCLI_PATH";
      if [ ! -x "$UNDERTALEMODCLI_PATH" ]; then
        echo "Could not build NF:"
        echo "Couldn't set UndertaleModCli as an executable. Do it yourself."
        exit 1
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


echo "-----------------------------------"
echo "Merging into Nubby's Number Factory"
echo "-----------------------------------"

"$UNDERTALEMODCLI_PATH" load "$NNF_PATH/clean_data.win" --scripts "./merger.csx" --output "$NNF_PATH/data.win"

if [ -z "$GAME_RUN_COMMAND" ]; then
  echo "All done!"
  exit 0
fi

echo "Running game..."
eval "$GAME_RUN_COMMAND"


if [ -z "$SLIP_PATH" ]; then
  echo "All done!"
  exit 0
fi


if [ ! -x "$SLIP_PATH" ]; then
  echo ""
  echo "slip is not set as executable. Please run"
  echo "chmod +x path/to/slip"
  read -p "Try running the command? (y/n): " answer
  if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
      chmod +x "$SLIP_PATH";
      if [ ! -x "$SLIP_PATH" ]; then
        echo "Could not launch slip:"
        echo "Couldn't set slip as an executable. Do it yourself."
        exit 0
      else
        echo "Success. Launching slip."
      fi
  else
      exit 1
  fi
fi

echo "Starting logger..."
"$SLIP_PATH"