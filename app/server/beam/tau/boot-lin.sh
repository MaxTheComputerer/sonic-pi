#!/bin/bash
set -e # Quit script on error
SCRIPT_DIR="$(dirname "$0")"
cd "${SCRIPT_DIR}"

echo "Booting Tau on Linux..."

if [ $TAU_ENV = "prod" ]
then
  # Ensure prod env has been setup with:
  # export MIX_ENV=dev
  # mix tau.release

  export MIX_ENV=prod
  _build/prod/rel/tau/bin/tau start > /dev/null 2>&1
elif [ $TAU_ENV = "dev" ]
then
  # Ensure prod env has been setup with:
  # export MIX_ENV=dev
  # mix setup.dev

  export MIX_ENV=dev
  mix assets.deploy.dev
  mix run --no-halt > log/tau_stdout.log 2>&1
elif [ $TAU_ENV = "test" ]
then
  export MIX_ENV=test
  export TAU_MIDI_ENABLED=false
  export TAU_LINK_ENABLED=false
  mix run --no-halt > log/tau_stdout.log 2>&1
else
  echo "Unknown TAU_ENV ${TAU_ENV} - expecting one of prod, dev or test."
fi
