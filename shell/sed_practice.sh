

# MQTT Broker 服务器地址（与设备上填写的一致）
mqtt_ip=128.128.12.80
# 设备 UUID
device_uuid=umpheanxjrvd

# type，用于 AddPerson 接口。1是base64注册；2是特征值注册；3是IC卡号注册
type=1
# photoType 用于 batchAddPerson 接口 //0 url, 1 pic, 2 feature
photoType=2

# start 用于确定批量删除的起点
start=59990
# end 用于确定批量删除的终点
end=60020

# personId 人员Id
PersonId=10000


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


# 使用 sed，编辑 photoType 类型
sed -i -r '4250,4750s/int photoType = [0-9]/int photoType = '${photoType}'/g' ${mqtt_demo_path}/main.cpp

# 编辑 PersonId
sed -i -r '3250,3750s/root, \"PersonId\", \"[^\"]+\"/root, \"PersonId\", \"'${PersonId}'\"/g' ${mqtt_demo_path}/main.cpp



# 使用 sed，编辑 start
sed -i -r '4000,4600s/int start = [0-9]+/int start = '${start}'/g' ${mqtt_demo_path}/main.cpp
# 使用 sed，编辑 end
sed -i -r '4000,4600s/,end = [0-9]+/,end = '${end}'/g' ${mqtt_demo_path}/main.cpp


# 执行 make 命令
$(cd ${mqtt_demo_path};make clean;make;)


echo -e "\e[32m\n--------------------> \t\n\n修改完成！ \n"
echo -e "\e[31m修改结果\e[32m"
echo "『MQTT Broker Server IP地址』"
cat ${mqtt_demo_path}/main.cpp | grep ${mqtt_ip}
echo "『设备 UUID』"
cat ${mqtt_demo_path}/main.cpp | grep ${device_uuid}
echo -e " --------------------> \e[0m"






# 开始运行程序

cur_dir=${PWD}

cd ${mqtt_demo_path};

./demo_x64 $1

cd ${cur_dir}