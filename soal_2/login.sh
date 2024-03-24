#!/bin/bash

echo "Welcome to the login system"
echo "1. Login"
echo "2. Forgot Password"

read command

if [[ $command -eq 1 ]]; then

  echo "Enter your email:"
  read inp_email

  email_found=false

  mapfile -t lines < users.txt

  for line in "${lines[@]}"; do
     
    IFS=':' read -r db_email db_username db_question db_answer db_password <<< "$line"

    if [[ $inp_email == $db_email ]]; then

      email_found=true
      echo "Enter your password:"
      read -s inp_password
      decrypted_password=$(echo "$db_password" | base64 -d)
      
      if [[ $inp_password == $decrypted_password ]]; then

        echo "$(date +'%d/%m/%y %H:%M:%S') LOGIN SUCCESS User with email $inp_email logged in successfully" >> auth.log
        echo "Login successful!"
        break

      else
        echo "$(date +'%d/%m/%y %H:%M:%S') LOGIN FAILED Failed login attempt on user with email $inp_email" >> auth.log
        echo "Wrong password. Login Failed."
        exit 1

      fi

    fi

  done

  if [[ $email_found == false ]]; then
    echo "Email not registered."
    exit 1
  fi

  if [[ $inp_email =~ .*"admin".* ]]; then

    while true; do
  
      echo "Admin Menu"
      echo "1. Add User"
      echo "2. Edit User"
      echo "3. Delete User"
      echo "4. Logout"
      read command2
      
      if [[ $command2 -eq 1 ]]; then
      
        echo "Add a new user."

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
      
      elif [[ $command2 -eq 2 ]]; then
      
        echo "Edit an existing user"

        echo "Enter the email of the user you want to edit:"
        read ed_email

        mapfile -t users_array < users.txt

        for line in "${users_array[@]}"; do
            
          IFS=':' read -r db_email db_username db_question db_answer db_password <<< "$line"

          if [[ $ed_email == $db_email ]]; then

            echo "Do you want to change your email address? [y/n]"
            read change_email

            if [[ $change_email == "y" ]]; then

              while true; do

                echo "Enter your email:"
                read new_email

                if [[ $new_email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$ ]]; then

                  if grep -q "$new_email" users.txt; then

                    echo "Email already exists. Try again."

                  else

                    break

                  fi

                else

                  echo "Invalid email address. Try again."

                fi

              done

            fi

            while true; do
            
              echo "Enter new username:"
              read new_username

              if grep -q "^$new_username:" users.txt; then

                echo "Username already exists. Try again."

              else

                break

              fi

            done

            echo "Enter a new security question:"
            read new_secquest

            echo "Enter the new answer to your security question:"
            read new_answer

            while true; do

              echo "Enter a new password (8 characters minimum, at least 1 uppercase letter, at least 1 lowercase letter, at least 1 digit, at least 1 symbol, and not the same as your username, birthdate, or email address)"

              read -s new_password

              if [[ ${#new_password} -ge 8 && "$new_password" =~ [[:lower:]] && "$new_password" =~ [[:upper:]] && "$new_password" =~ [[:digit:]] ]]; then
                
                break

              else
              
                echo "Password is too weak. Try again."

              fi

            done

            new_password=$(echo -n "$new_password" | base64)

            if [[ $change_email == "y" ]]; then

              sed -i "/$ed_email/c\\$new_email:$new_username:$new_secquest:$new_answer:$new_password" users.txt
              echo "$(date +'%d/%m/%y %H:%M:%S') USER UPDATE SUCCESS User data with email $ed_email updated successfully." >> auth.log
              echo "User data updated successfully."

            else

              sed -i "/$ed_email/c\\$ed_email:$new_username:$new_secquest:$new_answer:$new_password" users.txt
              echo "$(date +'%d/%m/%y %H:%M:%S') USER UPDATE SUCCESS User data with email $ed_email updated successfully." >> auth.log
              echo "User data updated successfully."

            fi

          else

            echo "Email not registered."

          fi

        done
      
      elif [[ $command2 -eq 3 ]]; then
      
        echo "Delete an existing user"
        echo "Enter the email of the user you want to delete:"
        read del_email

        mapfile -t lines < users.txt

        email_found=false

        for line in "${lines[@]}"; do
          
          IFS=':' read -r db_email db__username db__question db__answer db__password <<< "$line"

          if [[ $del_email == $db_email ]]; then

            email_found=true
            
            if [[ $del_email =~ $inp_email ]]; then

              echo "You can't delete this user. You are logged in as this user."

              break

            elif [[ $del_email =~ .*"admin".* ]]; then

              echo "You can't delete this user. This is an admin account."

              break

            fi
            
            sed -i "/$del_email/d" users.txt
            echo "$(date +'%d/%m/%y %H:%M:%S') USER DELETE SUCCESS User with email $del_email deleted successfully." >> auth.log
            echo "User deleted successfully."
           
            break

          fi

        done

        if [[ $email_found == false ]]; then
          
          echo "Email not registered."

        fi
      
      elif [[ $command2 -eq 4 ]]; then
      
        exit 1
      
      else 
      
        echo "Command not found."
        exit 1
      
      fi

    done  
    
  else

    echo "You don't have admin privileges. Welcome!"
    exit 1

  fi

elif [[ $command -eq 2 ]]; then

  echo "Forgot your password?"
  echo "Enter your email:"
  read inp_email

  mapfile -t lines < users.txt

  email_found=false

  for line in "${lines[@]}"; do
     
    IFS=':' read -r db_email db_username db_question db_answer db_password <<< "$line"
    
    if [[ $inp_email == $db_email ]]; then
      email_found=true
      
      echo "Security question: $db_question"
      echo "Enter your answer: "
      read inp_answer

      if [[ $inp_answer == $db_answer ]]; then

        decrypted_password=$(echo "$db_password" | base64 -d)
        echo "Your password is: $decrypted_password"

        echo "Do you want to change your password? [y/n]"
        read change_password

        if [[ $change_password == "y" ]]; then
          while true; do
            echo "Enter a new password (8 characters minimum, at least 1 uppercase letter, at least 1 lowercase letter, at least 1 digit, at least 1 symbol, and not the same as your username, birthdate, or email address)"
            read -s new_password

            if [[ ${#new_password} -ge 8 && "$new_password" =~ [[:lower:]] && "$new_password" =~ [[:upper:]] && "$new_password" =~ [[:digit:]] && "$new_password" =~ [[:punct:]] ]]; then
              break
            else
              echo "Password is too weak. Try again."
            fi
            
          done

          new_password=$(echo -n "$new_password" | base64)
          sed -i "/$inp_email/c\\$inp_email:$db_username:$db_question:$db_answer:$new_password" users.txt
          echo "$(date +'%d/%m/%y %H:%M:%S') PASSWORD UPDATE SUCCESS User with email $inp_email updated password successfully" >> auth.log
          echo "Password updated successfully."

        fi

        echo "$(date +'%d/%m/%y %H:%M:%S') PASSWORD RECOVERY SUCCESS User with email $inp_email recovered password successfully" >> auth.log
        break

      else

        echo "Wrong answer. Password recovery failed."
        echo "$(date +'%d/%m/%y %H:%M:%S') PASSWORD RECOVERY FAILED Failed password recovery attempt on user with email $inp_email" >> auth.log
        exit 1

      fi

    fi

  done

  if [[ $email_found == false ]]; then
      echo "Email not registered."
      exit 1
  fi

else

  echo "Command not found."
  exit 1

fi
