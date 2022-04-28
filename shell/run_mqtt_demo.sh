#
#
red_color="\e[31m"
green_color="\e[32m"
default_color="\e[0m"
#
#
# --------------------> 变量  <--------------------

# MQTT 服务器地址
mqtt_server_ip=
# 设备 UUID
device_uuid=

# 用户唯一标识，用于储存用户配置文件
user_uuid=$(who am i | awk '{print $1$5}')
# 配置储存地址
config_path='.mqtt_demo_run_config'
# 配置文件地址
config_file="${config_path}/${user_uuid}.config"

# 正则表达式匹配 IP 地址
ip_regex_pattern='[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
# uuid 正则
uuid_regex_pattern='device_uuid#[0-9a-zA-Z]+'


# 测试用例数据
csv_data_file="./test_case.csv"
# 去重后的文件
uniq_test_case_file="${config_path}/${user_uuid}--uniq_test_case.bak"
# 去重后的文件
uniq_test_case_content_file="${config_path}/${user_uuid}--uniq_test_case_content.bak"
# 中转文件
temp_file="${config_path}/${user_uuid}-temp"
#


# --------------------> 用户界面  <--------------------

# showUI 展示用户界面
# 第一个参数：界面标题
# 第二个参数：顶部导航栏
# 第三个参数：正文内容
# 第四个参数：获取用户输入
# 第五个参数：展示视图所使用的函数名称
function ShowUI(){
    title=$1
    top_text=$2
    center_text=$3
    read_input_text=$4
    controller_name=$5
    
    #clear
    echo -e "\n\n"
    echo -e "--------------------------------------------------------------------------------"
    echo -e "${red_color} ${title} ${default_color}"
    echo -e "--------------------------------------------------------------------------------"
    echo -e ${top_text}
    echo -e "\n\n"
    
    echo -e ${center_text}
    echo -e "\n"

    read  -p "${read_input_text}" input 

    # 回调函数，用于处理用户的输入
    Callback "${controller_name}" "${input}"
}






## --------------------> 控制层  <--------------------
#
# 改变 MQTT 服务器的地址
function ChangeMqttServerIP(){
    getMqttServerIP ${config_path}
    title='确定 MQTT 服务器地址'
    top_text="『退出（Esc)』\t\t『下一步（Enter）』"
    center_text="当前 MQTT 服务器地址为：${mqtt_server_ip}" 
    read_input_text="修改请输入新的IP（不修改，请敲击回车）："
    ShowUI "${title}" "${top_text}" "${center_text}" "${read_input_text}" 'ChangeMqttServerIP'
}
#
#
# 改变设备 UUID
function ChangeDeviceUUID(){
    getUUID ${config_path}
    title="确定设备 uuid "
    top_text="『退出（Esc)』\t\t『下一步（Enter）』\t\t『上一步（Tab）』"
    center_text="当前设备 uuid 为：${green_color}${device_uuid}${default_color}"
    read_input_text="修改请输入新的uuid（不修改，请敲击回车）："
    ShowUI "${title}" "${top_text}" "${center_text}" "${read_input_text}" 'ChangeDeviceUUID'
}
#
#
# 显示所有测试用例
function ShowAllTestCase(){
    # 独特的测试用例
    CollectUniqTestCase
    title="显示所有 case "
    top_text="『退出（Esc)』\t\t『下一步（Enter）』\t\t『上一步（Tab）』"
    

    center_text=""
    count=0
    for c in ${test_case_list};
    do
	    case_num=$(echo $c | awk -F'#' '{print $1}')
	    case_name=$(echo $c | awk -F'#' '{print $2}')
	    center_text="${center_text}[${case_num}] ${case_name}\t\t"
	    count=$(( count + 1 ))
	    if [ ${count} -eq 3 ]; then
		    center_text="${center_text}\n"
		    count=0
	    fi
    done




    read_input_text="选择 case："
    ShowUI "${title}" "${top_text}" "${center_text}" "${read_input_text}" 'ShowAllTestCase'
}
#
#
#
# 显示该条目下的所有测试内容
function ShowAllTestContent(){
	echo $1 >> log
	father_test_case_num=$1
	echo ---$1 > log
	
	for test_case in ${test_case_list}; do
		ret=$(echo ${test_case} | grep "${father_test_case_num}#" | awk -F'#' '{print $2}')
		if [ -n "$ret" ] ;then
		father_test_case=${ret}
               cur_test_case_content=${father_test_case_num}

	fi
	done

        CollectUniqTestCaseContent "${father_test_case}"

	#echo ${father_test_case} >> log



    title="显示测试内容 "
    top_text="『退出（Esc)』\t\t『下一步（Enter）』\t\t『上一步（Tab）』"

    
    center_text=""
	count=1
    for c in ${test_case_content_list}; do
	    case_num=$(echo $c | awk -F'#' '{print $1}')
	    case_content=$(echo $c | awk -F'#' '{print $2}')
		line="[${count}]\t${case_content}"
	    center_text="${center_text}${line}\n"
		count=$(( count + 1 ))
    done


    read_input_text="选择测试内容："
    ShowUI "${title}" "${top_text}" "${center_text}" "${read_input_text}" 'ShowAllTestContent'
}




# 查询一个记录
function ShowOneTestContent(){
	input=$1
    title="具体接口 "
    top_text="『退出（Esc)』\t\t『下一步（Enter）』\t\t『上一步（Tab）』"


	# 获取到一个测试用例对象
    test_case_content_listArr=(${test_case_content_list})
	case_num=$(echo ${test_case_content_listArr[(( input - 1))]} | awk -F'#' '{print $1}')
	case_content=$(echo ${test_case_content_listArr[(( input - 1))]} | awk -F'#' '{print $2}')
    one=$(cat ${csv_data_file} | tail +3 | grep "${case_num},")

    # 对其进行解析

    step="[操作步骤]\n\t"$(echo $one | awk -F',' '{print $5}')"\n"
    expect="[预期结果]\n\t"$(echo $one | awk -F',' '{print $6}')"\n"
	# param="[参数列表]\n\t"


    center_text="${step}${expect}"


    read_input_text="执行测试  "
    ShowUI "${title}" "${top_text}" "${center_text}" "${read_input_text}" 'ShowOneTestContent'
}



# 回调函数，用以处理用户的输入
function Callback(){
    controller_name=$1
    input=$2


#    # 如果参数为空
#    case "${input}" in
#	    "")
#		    ReloadViewUI "$controller_name"
#		    return
#		    ;;
#    esac



#    case "${controller_name}" in
#        "ShowAllTestContent") 
#            deal1 ${input}
#            ;;
#    esac
#




    # 设置参数专用

    

    # 设置变量的值
    case "${controller_name}" in
        "ChangeMqttServerIP") 
		    case "${input}" in
			    "")
		    JumpViewUI "$controller_name" "${input}"
		    return
		    ;;
		    esac
            deal1 ${input}
	    JumpViewUI "$controller_name" "${input}"
            ;;
    "ChangeDeviceUUID")
		    case "${input}" in
			    "")
		    JumpViewUI "$controller_name" "${input}"
		    return
		    ;;
		    esac
	    deal2 ${input}
	    JumpViewUI "$controller_name" "${input}"
	    ;;
    "ShowAllTestCase")
		    case "${input}" in
			    "")
		    ReloadViewUI "$controller_name" 
		    return
		    ;;
		    esac
		    JumpViewUI "${controller_name}" "${input}"
	    ;;
    "ShowAllTestContent")
		    case "${input}" in
			    "")
		    ReloadViewUI "$controller_name" "${cur_test_case_content}"
		    return
		    ;;
		    esac
		    JumpViewUI "${controller_name}" "${input}"
	    ;;
        *)
            echo "2error" 
    esac

    # 设置完成数值之后，依然需要跳转视图
}

#
## 跳转 UI 视图
function JumpViewUI(){
	controller_name=$1
	input=$2
	#echo ${controller_name} >> log
	case "${controller_name}" in 
		"ChangeMqttServerIP")
			ChangeDeviceUUID "${input}"
			;;
		"ChangeDeviceUUID")
			ShowAllTestCase "${input}"
			;;
		"ShowAllTestCase")
			ShowAllTestContent "${input}"
			;;
		"ShowAllTestContent")
			ShowOneTestContent "${input}"
			;;
		*)
			echo "1error"
	esac
}


# 重新加载 UI 视图
function ReloadViewUI(){
	controller_name=$1
	input=$2
	case "${controller_name}" in 
		"ChangeMqttServerIP")
			ChangeMqttServerIP "${input}"
			;;
		"ChangeDeviceUUID")
			ChangeDeviceUUID "${input}"
			;;
		"ShowAllTestCase")
			ShowAllTestCase "${input}"
			;;
		"ShowAllTestContent")
			ShowAllTestContent "${input}"
			;;
		*)
			echo "3error"
	esac

}



#
## --------------------> 数据操作层  <--------------------

# 测试用例列表
test_case_list=
# 测试内容列表
test_case_content_list=

#
cur_test_case_content=


#
#
# 从配置文件中获得 mqtt server 的 IP 地址
function getMqttServerIP(){
    if [ -f ${config_file} ]; then
	    mqtt_server_ip=$(cat ${config_file} | grep mqtt_server_ip | awk -F'#' '{print $2}')
    fi
    # 如果配置文件不存在，则不进行任何处理
}


# 设置 mqtt server 的 IP 地址
function deal1(){
	# 文件存在则，修改文件中的内容为当前 IP 地址。并更新全局变量 mqtt_server_ip
	mqtt_server_ip=$1
	if [ -f ${config_file} ]; then
		sed -i -r "s/${ip_regex_pattern}/${mqtt_server_ip//\./\\.}/g" ${config_file}
	else
		echo 'mqtt_server_ip#'${mqtt_server_ip} > ${config_file}
	fi
	# 文件不存在，则新建一个文件

	# 如果获取不到数值，则将本数值添加到文件中
	_mqtt_server_ip=$(echo ${config_file} | grep mqtt_server_ip | awk -F'#' '{print $2}')
	if [ "_mqtt_server_ip" == "" ]; then
		sed -i -r "s/mqtt_server_ip#[^\n]\+/mqtt_server_ip#${mqtt_server_ip//\./\\.}/g" ${config_file}
	fi
}


## 从配置文件中获得 device uuid 信息
function getUUID(){
    if [ -f ${config_file} ]; then
	    device_uuid=$(cat ${config_file} | grep device_uuid | awk -F'#' '{print $2}')
    fi
}


# 设置 device uuid
function deal2(){
	# 文件存在则，修改文件中的内容为当前 UUID。并更新全局变量 device_uuid
	device_uuid=$1
	if [ -f ${config_file} ]; then
		sed -i -r "s/${uuid_regex_pattern}/device_uuid#${device_uuid//\./\\.}/g" ${config_file}
	else
		echo 'device_uuid#'${device_uuid} > ${config_file}
	fi
	# 文件不存在，则新建一个文件

	# 如果获取不到数值，则将本数值添加到文件中
	_device_uuid=$(cat ${config_file} | grep device_uuid | awk -F'#' '{print $2}')
	#echo ${device_uuid}
	#echo ${_device_uuid}

	if [ -z "${_device_uuid}" ]; then
		echo 'device_uuid#'${device_uuid} >> ${config_file}
	fi
}



# 测试用例去重收集
function CollectUniqTestCase(){
	cat ${csv_data_file} | tail +3 | awk -F',' '{printf "%s#%s\n", $2,$3}'  > ${temp_file}

	uniq ${temp_file} > ${uniq_test_case_file}

	test_case_list=$(cat ${uniq_test_case_file})
}




# 测试用例去重收集
function CollectUniqTestCaseContent(){
	##cat $1"-CollectUniqTestCaseContent" >> log
	cat ${csv_data_file} | tail +3 | grep ",$1," |  awk -F',' '{printf "%s#%s\n", $1,$4}'  > ${temp_file}

	uniq ${temp_file} > ${uniq_test_case_content_file}

	test_case_content_list=$(cat ${uniq_test_case_content_file})
}


## --------------------> 函数入口  <--------------------
#
# 主函数
function Main(){
    # 选择 mqtt server 的 IP 地址
    ChangeMqttServerIP
}
#
#
#
# 开始执行函数
Main
#
#
#
#
#
#
#
##showUI    
