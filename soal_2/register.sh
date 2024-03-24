#!/bin/bash

echo "Welcome to Registration System"

while true; do

  echo "Enter your email:"
  read email

  if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$ ]]; then

    if grep -q "$email" users.txt; then

      echo "Email already exists. Try again."

    else

      break

    fi

  else
    
    echo "Invalid email address. Try again."

  fi

done

while true; do

  echo "Enter your username:"
  read username

  if grep -q "^$username:" users.txt; then

    echo "Username already exists. Try again."

  else

    break

  fi

done

echo "Enter a security question:"
read secquest

echo "Enter the answer to your security question:"
read answer

while true; do
    echo "Enter a password (8 characters minimum, at least 1 uppercase letter, at least 1 lowercase letter, at least 1 digit, at least 1 symbol, and not the same as your username, birthdate, or email adress)"
    read -s password

    if [[ ${#password} -ge 8 && "$password" =~ [[:lower:]] && "$password" =~ [[:upper:]] && "$password" =~ [[:digit:]] && "$password" =~ [[:punct:]] ]]; then
      break
    else
      echo "Password is too weak. Try again."
    fi
done

password=$(echo -n "$password" | base64)

echo "$email:$username:$secquest:$answer:$password" >> users.txt
echo "$(date +'%d/%m/%y %H:%M:%S') REGISTER SUCCESS User $username registered successfully" >> auth.log
echo "User Registered Successfully!"
