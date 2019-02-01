#!/bin/bash
#
# Script to update Webpack-React-Boilerplate
#
# Version 0.0.1 - Copyright (c) 2019 by Matt Carlotta
#

#===============================================================================##
## GLOBAL VARIABLES                                                              #
##==============================================================================##

# paths used by crontab for running commands
gGitCommand="/usr/bin/git"
gNPMCommand="/usr/bin/npm"
gNCUCommand="/usr/bin/ncu"

# directories
gDocumentsPath="$HOME/Documents"
gMasterPlate="$gDocumentsPath/boilerplate-master"
gHotPlate="$gDocumentsPath/boilerplate-hot"
gFullStackPlate="$gDocumentsPath/boilerplate-fullstack"

# log file
gLogPath="$HOME/Desktop/updates.log"

# current date
gCurrentDate=$(/bin/date +"%m/%d/%Y")

# current time
gCurrentTime=$(/bin/date +"%I:%M %p")

#===============================================================================##
## END SESSION                                                                   #
##==============================================================================##
function _end_session()
{
  printf "%s------------------------------------ END OF SESSION -------------------------------------------------\n\n" >> "$gLogPath"
  exit 0
}

#===============================================================================##
## BEGIN SESSION -- PRINTS A SESSION TO gLogPath                                 #
##==============================================================================##
function _begin_session()
{
  printf "%s------------------------------------ SESSION STARTED ON $gCurrentDate ----------------------------------\n" >> "$gLogPath"
}

#===============================================================================##
## COMMIT UPDATES -- INSTALLS NEW DEPENDENCIES TO LOCAL DIRECTORY                #
##==============================================================================##
function _install_updates()
{
  printf "\n%s------------------------------------ NPM SESSION ----------------------------------------------------\n" >> "$gLogPath"

  $($gNPMCommand install > /dev/null 2>&1)
  if [[ $? -ne 0 ]];
    then
      printf 'ERROR! Unable to install new package dependencies!\n' >> "$gLogPath"
      _end_session
    else
      printf 'Installed new package dependencies!\n' >> "$gLogPath"
  fi

  printf "%s-----------------------------------------------------------------------------------------------------\n\n" >> "$gLogPath"
}

#===============================================================================##
## COMMIT UPDATES -- PUSHES UPDATES TO GITHUB                                    #
##==============================================================================##
function _commit_updates()
{
  local checkstatus=$($gGitCommand status > /dev/null 2>&1)

  if [[ ! "$checkstatus" =~ "nothing to commit, working tree clean" ]]; then
    printf "\n%s------------------------------------ GIT SESSION ----------------------------------------------------\n" >> "$gLogPath"

    $($gGitCommand add .)
    printf "Added git changes to current branch\n" >> "$gLogPath"

    $($gGitCommand commit -m "Updated packages on $gCurrentDate @ $gCurrentTime" > /dev/null 2>&1)
    if [[ $? -ne 0 ]];
      then
        printf 'ERROR! Unable to commit new updates!\n' >> "$gLogPath"
        _end_session
      else
        printf "Added a new commit: Updated packages on $gCurrentDate @ $gCurrentTime\n" >> "$gLogPath"
    fi

    $($gGitCommand push origin master)
    if [[ $? -ne 0 ]];
      then
        printf 'ERROR! Unable to push new git commit!\n' >> "$gLogPath"
        _end_session
      else
        printf 'Successfully pushed new package dependencies to github!\n' >> "$gLogPath"
    fi

    printf "%s-----------------------------------------------------------------------------------------------------\n" >> "$gLogPath"

    _install_updates
  fi
}

#===============================================================================##
## UPDATE DEPENDENCIES -- UPDATE BOILERPLATE DEPENDENCIES                        #
##==============================================================================##
function _update_deps()
{
  local updatedpackages=$($gNCUCommand -u -a)

  printf "\n%s------------------------------------ UPDATED PACKAGES -----------------------------------------------\n" >> "$gLogPath"

  printf "$updatedpackages\n" >> "$gLogPath"

  printf "%s-----------------------------------------------------------------------------------------------------\n" >> "$gLogPath"

  _commit_updates
}

#===============================================================================##
## CHECK DEPENDENCIES -- CHECK BOILERPLATE DEPENDENCIES                          #
##==============================================================================##
function _check_for_outdated_deps()
{
  cd "$gMasterPlate"
  local outdatedpackages=$($gNPMCommand outdated)

  if [ ! -z "$outdatedpackages" ]; then
    printf "\n%s------------------------------------ OUTDATED PACKAGES ----------------------------------------------\n" >> "$gLogPath"

    printf "$outdatedpackages \n" >> "$gLogPath"

    printf "%s-----------------------------------------------------------------------------------------------------\n" >> "$gLogPath"

    _update_deps
  fi
}

#===============================================================================##
## MAIN -- RUNS MAIN SCRIPT                                                      #
##==============================================================================##
function main()
{
  _begin_session
  _check_for_outdated_deps
  _end_session
}

main

#===============================================================================##
## EOF                                                                           #
##==============================================================================##
