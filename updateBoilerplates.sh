#!/bin/bash
#
# Script to automatically update Webpack-React-Boilerplate
#
# Version 0.0.9 - Copyright (c) 2019 by Matt Carlotta
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
gSSRPlate="$gDocumentsPath/boilerplate-ssr"
gFullStackPlate="$gDocumentsPath/boilerplate-fullstack"

# directory list
gDirList=($gMasterPlate $gHotPlate $gSSRPlate $gFullStackPlate)

# current directory list
gCurrentDir=""

# count to cycle thru directory list
gCount=0

# log file
gLogPath="$HOME/Documents/updateBoilerplate/updates.log"

# current date
gCurrentDate=$(/bin/date +"%m/%d/%Y")

# current time
gCurrentTime=$(/bin/date +"%I:%M %p")

# if ctrl+c, then exit script
trap '{ exit 0; }' INT

#===============================================================================##
## INSTALL UPDATES -- INSTALLS NEW DEPENDENCIES TO LOCAL DIRECTORY               #
##==============================================================================##
function _install_updates()
{
  $($gNPMCommand i > /dev/null 2>&1)
    printf "Installed new package dependencies $gCurrentDir!\n" >> "$gLogPath"

    if [[ $gCount -eq 4 ]]; then
      cd "client"
      ((gCount++))
      _install_updates
    fi
}

#===============================================================================##
## COMMIT UPDATES -- PUSHES UPDATES TO GITHUB                                    #
##==============================================================================##
function _commit_updates()
{
  local checkstatus=$($gGitCommand status)

  if [[ ${checkstatus} == *"Changes not staged for commit"* ]];
    then
      $($gGitCommand add .)
      printf "Added git changes to current branch\n" >> "$gLogPath"

      $($gGitCommand commit -m "Updated packages on $gCurrentDate @ $gCurrentTime" > /dev/null 2>&1)
      printf "Added a new commit: Updated packages on $gCurrentDate @ $gCurrentTime\n" >> "$gLogPath"

      $($gGitCommand push)
      if [[ $? -ne 0 ]];
        then
          printf "ERROR! Unable to push new git commit! $gCurrentDir - reason: $? \n" >> "$gLogPath"
          _end_session
        else
          printf "Successfully pushed new package dependencies to github!\n" >> "$gLogPath"
          _install_updates
      fi
    else
      printf "Nothing to commit.\n" >> "$gLogPath"
  fi
}

#===============================================================================##
## CHECK DEPENDENCIES -- CHECK BOILERPLATE DEPENDENCIES                          #
##==============================================================================##
function _check_for_outdated_deps()
{
  local outdatedpackages=$($gNPMCommand outdated)

  if [ -z "$outdatedpackages" ];
    then
      printf "All package dependencies are up-to-date! :)\n\n" >> "$gLogPath"
    else
      printf "$outdatedpackages\n\n" >> "$gLogPath"
  fi
}

#===============================================================================##
## UPDATE FULLSTACK CLIENT DEPENDENCIES --                                       #
##==============================================================================##
function update_fullstack_client_deps()
{
  if [[ $gCount -eq 3 ]]; then
    cd "client"
    ((gCount++))
    _check_for_outdated_deps
    _update_deps
    cd "$gCurrentDir"
  fi
}

#===============================================================================##
## UPDATE DEPENDENCIES -- UPDATE CURRENT BOILERPLATE DEPENDENCIES                #
##==============================================================================##
function _update_deps()
{
  local updatedpackages=$($gNPMCommand upgrade)

  if [[ ${updatedpackages} != *"All dependencies match the latest package versions"* ]]; then
      printf "$updatedpackages\n\n" >> "$gLogPath"
  fi
  update_fullstack_client_deps

}

#===============================================================================##
## CLOSE DIRECTORY LOG -- CLOSE CURRENT WORKING DIRECTORY                        #
##==============================================================================##
function _close_current_dir_log()
{
  printf "\nClosing $gCurrentDir\n" >> "$gLogPath"
  printf "\n%s-----------------------------------------------------------------------------------------------------\n" >> "$gLogPath"
}

#===============================================================================##
## UPDATE DIRECTORY LOG -- UPDATE CURRENT WORKING DIRECTORY                      #
##==============================================================================##
function _update_current_dir_log()
{
  printf "\nUpdating $gCurrentDir\n\n" >> "$gLogPath"
}

#===============================================================================##
## SET DIRECTORY -- SETS CURRENT WORKING DIRECTORY                               #
##==============================================================================##
function _set_current_dir()
{
  for i in ${!gDirList[@]}
  do
    gCount=$i
    gCurrentDir="${gDirList[$i]}"
    cd "$gCurrentDir"
    _update_current_dir_log
    _check_for_outdated_deps
    _update_deps
    _commit_updates
    _close_current_dir_log
  done
}

#===============================================================================##
## END SESSION                                                                   #
##==============================================================================##
function _end_session()
{
  printf "%s------------------------------------ END OF SESSION -------------------------------------------------\n" >> "$gLogPath"
  printf "%s-----------------------------------------------------------------------------------------------------\n\n" >> "$gLogPath"
  exit 0
}

#===============================================================================##
## BEGIN SESSION -- PRINTS A SESSION TO gLogPath                                 #
##==============================================================================##
function _begin_session()
{
  printf "%s-----------------------------------------------------------------------------------------------------\n" > "$gLogPath"
  printf "%s------------------------------------ SESSION STARTED ON $gCurrentDate ----------------------------------\n" >> "$gLogPath"
  printf "%s-----------------------------------------------------------------------------------------------------\n" >> "$gLogPath"

  _set_current_dir
}

#===============================================================================##
## MAIN -- RUNS MAIN SCRIPT                                                      #
##==============================================================================##
function main()
{
  _begin_session
  _end_session
}

main

#===============================================================================##
## EOF                                                                           #
##==============================================================================##
