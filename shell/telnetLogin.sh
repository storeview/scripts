# Telnet auto login by lilnfh
# v1 ~ 2021-11-4

# set color code
green_color="\e[1;32m"
red_color="\e[1;31m"
color_end="\e[0m"

# if the IP don't exist, then exit the program
if [ -z "$1" ]; then
	echo "ERROR: Please input a ip"
	exit
fi

ip=$1
username=root

# if the IP don't online, then do nothing
ping $ip -c1 -w1&>/dev/null
if [ $? -ne 0 ]; then
	echo -e "${red_color}The $ip is offline.${color_end}"
	exit
else
	echo -e "${green_color}The $ip is online.${color_end}"
fi

# if dont store the ip's password, then save it 
passwords=("" "jvtsmart123" "smartjvt123" "fxsdkadmin" "fxjvtsmart")
password=$(cat .ip.txt 2>/dev/null | grep $ip | awk '{print $2}')
if [ -z "$password" ]; then
	echo "The ip(${ip}) haven't store, please select a PASSWORD:"
	echo -e "\e[1;34m"
	echo "    [1].${passwords[1]}     [2].${passwords[2]}    [3].${passwords[3]}    [4].${passwords[4]}"
	echo -e "\e[0m"
	read index
	password=${passwords[$index]}
	echo "$ip $password" >> .ip.txt
fi

# telnet auto login SCRIPT writed by expect
cat > telnetLogin.exp <<-EOF
	#!/usr/bin/expect
	set ip [lindex $argv 0]
	set username [lindex $argv 1]
	set password [lindex $argv 2]
	spawn telnet ${ip}
	expect "login:"
	send "${username}\n"
	expect "Password:"
	send "${password}\n"
	expect "*#"
	interact
EOF

chmod 777 telnetLogin.exp

# run the expect SCRIPT
./telnetLogin.exp $ip $username $password

# delete the temp SCRIPT
rm telnetLogin.exp
