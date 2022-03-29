# check ip list
# v1.0 by lilnfh at 2021-11-10

>online_ip.txt

for i in {1..255}
do
        (
        ip=128.128.1.$i
        ping -c1 -W1 $ip &>/dev/null
        if [ $? -eq 0 ]; then
                echo "$ip" | tee -a online_ip.txt
        fi
        )&
done

wait

echo "finish..."