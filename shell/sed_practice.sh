# MQTT Broker 服务器地址（与设备上填写的一致）
mqtt_ip=128.128.12.80
# 设备 UUID
device_uuid=test2022415v2
# type
type=2


mqtt_demo_path='/home/test/000/mqtt/bin/x64'


# 使用 sed，改变 MQTT Broker 地址
change_mqtt_ip_RegexPattern='char \*host = \(char \*\)\"[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\";'
change_mqtt_ip_Target='char \*host = \(char \*\)\"'${mqtt_ip//\./\\.}'\";'
sed -i -r "s/${change_mqtt_ip_RegexPattern}/${change_mqtt_ip_Target}/g" ${mqtt_demo_path}/main.cpp

# 使用 sed，填入待测设备的 uuid
change_device_uuid_RegexPattern='sprintf\(g_uuid,\"%s\",\"[^\"]+\"\);'
change_device_uuid_Target='sprintf\(g_uuid,\"%s\",\"'${device_uuid}'\"\);'
sed -i -r "s/${change_device_uuid_RegexPattern}/${change_device_uuid_Target}/g" ${mqtt_demo_path}/main.cpp

# 使用 sed，编辑 type 类型
sed -i -r '4000,4500s/int type = [0-9]/int type = '${type}'/g' ${mqtt_demo_path}/main.cpp


# 执行 make 命令
$(cd ${mqtt_demo_path};make clean;make;)


echo -e "\e[32m\n--------------------> \t\n\n修改完成！ \n"
echo -e "\e[31m修改结果\e[32m"
                                                                             