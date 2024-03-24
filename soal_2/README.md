# PENJELASAN SOAL SHIFT MODUL 1

## NOMOR 2

  Oppie merupakan seorang peneliti bom atom, ia ingin merekrut banyak peneliti lain untuk mengerjakan proyek bom atom nya, 
Oppie memiliki racikan bom atom rahasia yang hanya bisa diakses penelitinya yang akan diidentifikasi sebagai user, 
Oppie juga memiliki admin yang bertugas untuk memanajemen peneliti,  bantulah oppie untuk membuat program yang akan memudahkan 
tugasnya 

a. Buatlah 2 program yaitu login.sh dan register.sh

b. Setiap admin maupun user harus melakukan register terlebih dahulu menggunakan email, username, 
   pertanyaan keamanan dan jawaban, dan password

c. Username yang dibuat bebas, namun email bersifat unique. setiap email yang mengandung kata admin akan 
   dikategorikan menjadi admin 

d. Karena resep bom atom ini sangat rahasia Oppie ingin password nya memuat keamanan tingkat tinggi
   - Password tersebut harus di encrypt menggunakan base64
   - Password yang dibuat harus lebih dari 8 karakter
   - Harus terdapat paling sedikit 1 huruf kapital dan 1 huruf kecil
   - Harus terdapat paling sedikit 1 angka

e. Karena Oppie akan memiliki banyak peneliti dan admin ia berniat untuk menyimpan seluruh data register yang ia 
   lakukan ke dalam folder users file users.txt. Di dalam file tersebut, terdapat catatan seluruh email, username, 
   pertanyaan keamanan dan jawaban, dan password hash yang telah ia buat.

f. Setelah melakukan register, program harus bisa melakukan login. Login hanya perlu dilakukan menggunakan email dan password.

g. Karena peneliti yang di rekrut oleh Oppie banyak yang sudah tua dan pelupa maka Oppie ingin ketika login akan ada 
   pilihan lupa password dan akan keluar pertanyaan keamanan dan ketika dijawab dengan benar bisa memunculkan password

h. Setelah user melakukan login akan keluar pesan sukses, namun setelah seorang admin melakukan login Oppie ingin 
   agar admin bisa menambah, mengedit (username, pertanyaan keamanan dan jawaban, dan password), dan menghapus user 
   untuk memudahkan kerjanya sebagai admin. 

i. Ketika admin ingin melakukan edit atau hapus user, maka akan keluar input email untuk identifikasi user yang akan di 
   hapus atau di edit

j. Oppie ingin programnya tercatat dengan baik, maka buatlah agar program bisa mencatat seluruh log ke dalam folder users 
   file auth.log, baik login ataupun register.
   - Format: [date] [type] [message]
   - Type: REGISTER SUCCESS, REGISTER FAILED, LOGIN SUCCESS, LOGIN FAILED
   - Ex:
     [23/09/17 13:18:02] [REGISTER SUCCESS] user [username] registered successfully
     [23/09/17 13:22:41] [LOGIN FAILED] ERROR Failed login attempt on user with email [email]

## Solusi

Untuk menyelesaikan soal ini, saya akan membuat 2 file code bash yang bernama login.sh dan register.sh.

## 1. register.sh

Soal meminta untuk membuat sebuah code bash bernama register.sh yang bertujuan untuk menerima input 
data akun peneliti dan meletakkannya ke dalam file users.txt. Oleh karena itu pertama-tama program harus 
menerima input-input berikut:
1. Email
2. Username
3. Pertanyaan keamanan
4. Jawaban dari pertanyaan keamanan
5. Password

Berikut adalah cara kerja code register.sh yang kami buat

1. Menerima input email

Untuk input email, program hanya menerima input string yang sesuai dengan format
email pada umumnya (contoh@gmail.com). 

```
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
```

Jika user memberi input email yang sudah ada di database users.txt atau jika program 
memberikan input email dengan format yang tidak valid, maka program akan menanyakan kembali input hingga
user memberikan input yang benar.

2. Menerima input username

Untuk input username saya program supaya username yang diinput bersifat unique untuk mengantisipasi konflik data

```
while true; do

  echo "Enter your username:"
  read username

  if grep -q "^$username:" users.txt; then

    echo "Username already exists. Try again."

  else

    break

  fi

done
```

Program akan terus menanyakan input username hingga user memberikan username unique

3. input pertanyaan keamanan beserta jawabannya

```
echo "Enter a security question:"
read secquest

echo "Enter the answer to your security question:"
read answer
```

4. Input password

Karena soal memberikan beberapa kriteria untuk password yang bisa diinput oleh user maka saya membuat program untuk menanyakan
kembali password jika tidak memiliki minimal 1 huruf uppercase, lowercase, digit, dan symbol
( "$password" =~ [[:lower:]] && "$password" =~ [[:upper:]] && "$password" =~ [[:digit:]] && "$password" =~ [[:punct:]] )

dan juga mengandung setidaknya 8 karakter
( ${#password} -ge 8 )

```

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
```

Program akan menanyakan kembali input password jika belum memenuhi semua kriteria hingga semuanya sudah terpenuhi.
Kemudian program akan mengenkripsi password menggunakan base 64.
( password=$(echo -n "$password" | base64) )

5. Menyimpan input di users.txt

Setelah semua input sudah diberikan dan diletakkan di variabelnya masing-masing, program akan menyimpan semua data tersebut
di users.txt dalam satu line dan dipisahkan oleh titik dua (:).

```
echo "$email:$username:$secquest:$answer:$password" >> users.txt
```

Kemudian program akan membuat laporan keberhasilan registrasi user dan menyimpannya dalam file auth.log

```
echo "$(date +'%d/%m/%y %H:%M:%S') REGISTER SUCCESS User $username registered successfully" >> auth.log
echo "User Registered Successfully!"
```

Program berakhir.

## 2. login.sh

Selain opsi untuk login, soal juga meminta agar program memiliki opsi untuk password recovery jika user melupakan password
mereka. Oleh karena itu, ini adalah tampilan menu awal dari login.sh

```
echo "Welcome to the login system"
echo "1. Login"
echo "2. Forgot Password"

read command
```
Kemudian program akan menerima input angka yang sesuai dengan command yang diinginkan.

## A. Login

Berikut adalah jalan kerja program jika user memilih opsi 1. Login.

1. Input Email dan password

Untuk login, pertama user harus memberikan input email untuk akun yang ingin mereka gunakan

```
echo "Enter your email:"
read inp_email
email_found=false

mapfile -t lines < users.txt
```
Setelah itu program akan membaca isi dari users.txt dan meletakkannya ke dalam variabel lines dalam bentuk array.
Setiap array akan berisi 1 line dari users.txt.

```
for line in "${lines[@]}"; do
     
    IFS=':' read -r db_email db_username db_question db_answer db_password <<< "$line"
```
Kemudian program akan menjalankan loop untuk membaca setiap line users.txt yang berupa data. Kemudian program
memisahkan setiap baris dari file users.txt berdasarkan karakter titik dua (:) dan menetapkan bagian-bagiannya 
ke variabel yang sesuai seperti db_email, db_username, dst.

```
    if [[ $inp_email == $db_email ]]; then

      email_found=true
      echo "Enter your password:"
      read -s inp_password
      decrypted_password=$(echo "$db_password" | base64 -d)
```
Kemudian program akan memeriksa apakah email yang diinput user sudah teregistrasi. Kemudian program akan menanyakan
password yang sesuai dengan email yang diinput.

```   
      if [[ $inp_password == $decrypted_password ]]; then

        echo "$(date +'%d/%m/%y %H:%M:%S') LOGIN SUCCESS User with email $inp_email logged in successfully" >> auth.log
        echo "Login successful!"
        break
```
Kemudian program akan membandingkan password yang diinput dengan password yang ada di database. Jika password
sesuai dengan email yang diinput, maka program akan membuat laporan bahwa login berhasil dan memasukkannya ke
file auth.log.

```
      else
        echo "$(date +'%d/%m/%y %H:%M:%S') LOGIN FAILED Failed login attempt on user with email $inp_email" >> auth.log
        echo "Wrong password. Login Failed."
        exit 1

      fi

    fi

  done
```
Jika user menginput password yang salah, maka program akan membuat laporan bahwa login gagal dan mencatatnya di auth.log.

```

  if [[ $email_found == false ]]; then
      echo "Email not registered."
      exit 1
  fi
```

dan terakhir, jika email yang diinputkan user tidak ada di database (tidak teregistrasi) maka program akan berhenti.

## A.1. Menu Admin

Jika email yang diinput user memiliki kata "admin", maka user tersebut teregistrasi sebagai admin dan memiliki 
akses khusus. 

```
if [[ $inp_email =~ .*"admin".* ]]; then

    while true; do
  
      echo "Admin Menu"
      echo "1. Add User"
      echo "2. Edit User"
      echo "3. Delete User"
      echo "4. Logout"
      read command2
```
Ini adalah tampilan menu admin. Admin memiliki akses untuk menambah user, mengedit data user, dan menghapus user.
Program akan meminta user admin untuk memberikan input angka yang sesuai dengan command yang mereka inginkan.

```   
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
```
Jika user memilih command pertama (Add User). Maka program akan berjalan seperti program register.sh. Yaitu menerima input
data email, username, pertanyaan keamanan, jawaban, dan password. Dilanjutkan dengan meletakkan semua data tersebut ke
users.txt dan membuat laporan yang dicatat ke auth.log. Kemudian program akan mengembalikan user ke menu admin.

```
      
      elif [[ $command2 -eq 2 ]]; then
      
        echo "Edit an existing user"

        echo "Enter the email of the user you want to edit:"
        read ed_email
```
Jika user memilih opsi 2 (Edit User), pertama program akan menanyakan email dari user yang ingin diedit.

```
        mapfile -t users_array < users.txt

        for line in "${users_array[@]}"; do
            
          IFS=':' read -r db_email db_username db_question db_answer db_password <<< "$line"
```
Program akan membaca users.txt dan meletakkan isinya ke dalam variabel users_array

```
          if [[ $ed_email == $db_email ]]; then
```
Program memeriksa apakah email yang diinput ada di database.
```

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
```
Program menanyakan user apakah dia ingin mengubah emailnya atau tidak. Jika iya, maka program akan meminta
input email yang sesuai dengan format email pada umumnya (contoh@gmail.com) dan akan meminta input kembali
jika input belum sesuai.

```
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
```
Berikutnya program akan menanyakan untuk menginput data-data baru untuk username, pertanyaan keamanan, jawaban, dan password.
```

            if [[ $change_email == "y" ]]; then

              sed -i "/$ed_email/c\\$new_email:$new_username:$new_secquest:$new_answer:$new_password" users.txt
              echo "$(date +'%d/%m/%y %H:%M:%S') USER UPDATE SUCCESS User data with email $ed_email updated successfully." >> auth.log
              echo "User data updated successfully."

            else
```
Jika tadi user memilih untuk mengubah emailnya, maka program akan menukar seluruh line data yang berisi data lama dengan line data yang
berisi data baru. Setelah itu program akan melaporkan bahwa edit data user sukses dan mencatatnya di auth.log.

```

              sed -i "/$ed_email/c\\$ed_email:$new_username:$new_secquest:$new_answer:$new_password" users.txt
              echo "$(date +'%d/%m/%y %H:%M:%S') USER UPDATE SUCCESS User data with email $ed_email updated successfully." >> auth.log
              echo "User data updated successfully."

            fi
```
Jika tadi user memilih untuk tidak mengubah emailnya, maka program akan menukar line data yang berisi data lama dengan line data yang
berisi data baru kecuali emailnya. Setelah itu program akan melaporkan bahwa edit data user sukses dan mencatatnya di auth.log.

```

          else

            echo "Email not registered."

          fi

        done
```
Jika email yang diinput untuk memilih data user yang ingin diedit ternyata tidak ada di database (tidak teregistrasi),
maka program akan mengembalikan user ke menu admin.

Jika user memilih command 3 (Delete User). Maka pertama program akan menanyakan input email untuk memilih
akun user mana yang ingin dihapus.

```
      
      elif [[ $command2 -eq 3 ]]; then
      
        echo "Delete an existing user"
        echo "Enter the email of the user you want to delete:"
        read del_email

        mapfile -t lines < users.txt

        email_found=false

        for line in "${lines[@]}"; do
          
          IFS=':' read -r db_email db__username db__question db__answer db__password <<< "$line"
```
Kemudian program akan membaca users.txt dan meletakkan isinya ke dalam variabel lines.

```
          if [[ $del_email == $db_email ]]; then

            email_found=true
```
Program akan memeriksa apakah file yang diinput ada di database.
```
            
            if [[ $del_email =~ $inp_email ]]; then

              echo "You can't delete this user. You are logged in as this user."

              break

            elif [[ $del_email =~ .*"admin".* ]]; then

              echo "You can't delete this user. This is an admin account."

              break

            fi
```
Program akan menggagalkan perintah delete user jika user menginput email user admin atau user
yang sedang digunakan.

```
            
            sed -i "/$del_email/d" users.txt
            echo "$(date +'%d/%m/%y %H:%M:%S') USER DELETE SUCCESS User with email $del_email deleted successfully." >> auth.log
            echo "User deleted successfully."
           
            break

          fi

        done
```
Kemudian program akan menghapus seluruh line data yang bersesuaian dengan email yang diinput. Program kemudian
akan membuat laporan bahwa user telah dihapus dan mencatatnya di auth.log. Kemudian program akan mengembalikan
user ke menu admin

```

        if [[ $email_found == false ]]; then
          
          echo "Email not registered."

        fi
```
Jika email yang diinput tidak ditemukan di database (tidak teregistrasi), maka program akan mengembalikan
user ke menu admin.

```
      
      elif [[ $command2 -eq 4 ]]; then
      
        exit 1
```
Jika user memilih command 4 (Logout), maka program akan berhenti sepenuhnya. Jika user memberikan input
selain angka 1 - 4 maka program juga akan berhenti sepenuhnya.

```
      else 
      
        echo "Command not found."
        exit 1
      
      fi

    done  
    
  else

    echo "You don't have admin privileges. Welcome!"
    exit 1

  fi
```
Jika user login dengan email yang tidak mengandung kata "admin" maka user telah login
sebagai user biasa dan tidak memiliki akses untuk menjalankan perintah-perintah admin.

## B. Forgot Password

Jika pada menu utama program login.sh user memilih command 2 (Forgot Password), program
akan membantu user untuk mengembalikan password mereka.

Pertama program akan meminta input email untuk mencari akun user mana yang ingin ditampilkan
passwordnya.

```
elif [[ $command -eq 2 ]]; then

  echo "Forgot your password?"
  echo "Enter your email:"
  read inp_email

  mapfile -t lines < users.txt

  email_found=false

  for line in "${lines[@]}"; do
     
    IFS=':' read -r db_email db_username db_question db_answer db_password <<< "$line"
```
Setelah itu, program akan membaca users.txt dan meletakkan isinya ke dalam variabel lines.
```
    
    if [[ $inp_email == $db_email ]]; then
      email_found=true
      
      echo "Security question: $db_question"
      echo "Enter your answer: "
      read inp_answer
```
Jika email yang diinput ditemukan di database maka program akan melanjutkan dengan menampilkan pertanyaan
keamanan yang dimiliki akun dari email tersebut. Kemudian program akan meminta input jawaban dari user.

```

      if [[ $inp_answer == $db_answer ]]; then

        decrypted_password=$(echo "$db_password" | base64 -d)
        echo "Your password is: $decrypted_password"

        echo "Do you want to change your password? [y/n]"
        read change_password
```
Jika user menjawab benar, maka program akan mendekripsi dan menampilkan password mereka. Setelah itu program akan
menanyakan apakah user ingin mengubah passwordnya.
```

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
```
Jika user memilih untuk merubah password akunnya, maka program akan meminta input password baru yang harus sesuai kriteria 
password kuat yang telah disebutkan sebelumnya. Program akan terus meminta input hingga user memberikan password yang kuat.
Setelah itu, program akan membuat laporan bahwa user dengan email yang diinput telah merubah passwordnya dan mencatatnya
di auth.log.
```

        echo "$(date +'%d/%m/%y %H:%M:%S') PASSWORD RECOVERY SUCCESS User with email $inp_email recovered password successfully" >> auth.log
        break
```
Jika user tidak memilih untuk merubah passwordnya maka program akan melaporkan bahwa password recovery telah berhasil di lakukan
dan akan mencatatnya di auth.log.
```

      else

        echo "Wrong answer. Password recovery failed."
        echo "$(date +'%d/%m/%y %H:%M:%S') PASSWORD RECOVERY FAILED Failed password recovery attempt on user with email $inp_email" >> auth.log
        exit 1

      fi

    fi

  done

```
Jika jawaban yang diinput user salah, maka program akan melaporkan bahwa password recovery tidak berhasil dan mencatatnya di
auth.log.

```

  if [[ $email_found == false ]]; then
      echo "Email not registered."
      exit 1
  fi

else

  echo "Command not found."
  exit 1

fi
```
Jika user menginput email yang tidak teregister maka program akan berhenti seluruhnya.
Jika user menginput angka untuk command selain 1 dan 2 maka program akan berhenti seluruhnya.

Program selesai.








