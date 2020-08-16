#!/bin/bash

programs="${@}"

print_usage() {
  printf "Usage:\\n"
  printf "  ${0} <programs>\\n"
  printf "Examples:\\n"
  printf "  ${0} cp\\n"
  printf "  ${0} cp mv cat\\n"
}

check_for_program() {
  local program 
  program="${1}"

printf "Checking for ${program}\\n  "
  command -v "${program}"


  if [[ "${?}" -ne 0 ]]; then
    printf "${program} is not installed, exiting\\n"
    echo "do yo want to install it"
    read insta
    if [ $insta -eq '1' ];
    then
         sudo apt-get install $program
          exit 1
    fi
    fi 
}

main() {
  if [[ -z "${programs}" ]]; then 
    print_usage 
    exit 1
  fi 

  for p in ${programs}; do 
    check_for_program "${p}"
  done
}

main 
