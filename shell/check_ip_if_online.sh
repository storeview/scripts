#check ip if online
#v1.0 by lilnfh at  2021-11-10

red_col="\e[31m"
green_col="\e[32m"
reset_col="\e[0m"

ip_file=~/.ip.txt

for ip in `cat $ip_file | awk '{print $1}'`
do
        (
        ping -c1 -W1 $ip &>/dev/null
        if [ $? -eq 0 ] ;then
                echo -e "$green_col$ip is up$reset_col"
        else
                echo -e "$red_col$ip is down$reset_col"
        fi
        )&
done

wait

echo "finish..."