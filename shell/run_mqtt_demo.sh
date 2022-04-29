set -u
# do not catch ctrl+c, ctrl+z

trap "KillProgram" INT


# --------------------> 变量  <------------------------------------------------------------
mqtt_server_ip=                                                                                 # MQTT 服务器地址
device_uuid=                                                                                    # 设备 UUID
user_uuid=$(who am i | awk '{print $1$5}')                              # 用户唯一标识，用于储存用户配置文件
config_path='.mqtt_demo_run_config'                                             # 配置储存地址
working_dir="$PWD"


# --------------------> 用户界面  <------------------------------------------------------------
# 颜色
red_color="\e[31m"
green_color="\e[32m"
default_color="\e[0m"
yellow_color="\e[33m"


# showUI 展示用户界面
# 第一个参数：界面标题
# 第二个参数：底部导航栏
# 第三个参数：顶部用户信息
# 第三个参数：正文内容
# 第四个参数：获取用户输入
# 第五个参数：视图所使用的函数名称（可以看做 Route 路径）
function ShowUI() {
        title=$1
        bottom_title=$2
        buttons_name=$3
        center_text=$4
        read_input_text=$5
        controller_name=$6

        echo -e "\n\n"
        echo -e "\n\n"
        echo -e "\n\n"
        echo -e "\n\n"
        echo -e "\n\n"
        echo -e "\n\n"
        #clear
        echo -e "\n\n"
        echo -e "\t\t\t\t\t\t\t当前用户 ${yellow_color}${user_uuid}${default_color}"
        echo -e "-------------------------------------------------------------------------------------"
        echo -e "${red_color} ${title} ${default_color}"
        echo -e "-------------------------------------------------------------------------------------"
        echo -e "${bottom_title}"

        echo -e "\n\n\n\n"
        echo -e ${center_text}
        echo -e "\n\n\n\n"

        echo -e ${buttons_name}
        echo -e "-------------------------------------------------------------------------------------"

        echo -e "\n\n"
        read -p "${read_input_text}" input

        # 回调函数，用于处理用户的输入
        Callback "${controller_name}" "${input}"
}


## --------------------> 控制层  <--------------------
pre_controller=
pre_input=
cur_level=1
declare -A nav_controller_name
nav_controller_name=([1]='' [2]='' [3]='' [4]='' [5]='')
declare -A nav_input
nav_input=([1]='' [2]='' [3]='' [4]='' [5]='')
father_test_case_num=
father_test_case=
cur_case_num=
cur_test_case_content=
declare -A params
params=([type]='' [photoType]='' [start]='' [end]='' [PersonId]='')

# 改变 MQTT 服务器的地址
function ChangeMqttServerIP() {
        getMqttServerIpFromConfigServer ${config_path}

        title='确定 MQTT 服务器地址'
        bottom_title=" "
        buttons_name="『退出（Q)』\t\t『下一步（Enter）』"
        center_text="当前 MQTT 服务器地址为：${mqtt_server_ip}"
        read_input_text="修改请输入新的IP（不修改，请敲击回车）："

        ShowUI "${title}" "${bottom_title}" "${buttons_name}" "${center_text}" "${read_input_text}" 'ChangeMqttServerIP'
}

# 改变设备 UUID
function ChangeDeviceUUID() {
        GetUuidFromConfigFile ${config_path}

        bottom_title=" "
        title="确定设备 uuid "
        buttons_name="『退出（Q)』\t\t『下一步（Enter）』\t\t『上一步（R）』"
        center_text="当前设备 uuid 为：${green_color}${device_uuid}${default_color}"
        read_input_text="修改请输入新的uuid（不修改，请敲击回车）："

        ShowUI "${title}" "${bottom_title}" "${buttons_name}" "${center_text}" "${read_input_text}" 'ChangeDeviceUUID'
}

# 显示所有测试用例
function ShowAllTestCase() {
        # 获得不重复的测试用例编号
        GetUniqTestNum

        center_text=""
        count=0
        for c in ${test_case_num_list}; do
                case_num=$(echo $c | awk -F'#' '{print $1}')
                case_name=$(echo $c | awk -F'#' '{print $2}')
                center_text="${center_text}[${case_num}] ${case_name}\t\t"
                count=$((count + 1))
                if [ ${count} -eq 3 ]; then
                        center_text="${center_text}\n"
                        count=0
                fi
        done

        title="显示所有 case "
        bottom_title=" "
        buttons_name="『退出（Q)』\t\t『下一步（Enter）』\t\t『上一步（R）』"
        read_input_text="选择 case："

        ShowUI "${title}" "${bottom_title}" "${buttons_name}" "${center_text}" "${read_input_text}" 'ShowAllTestCase'
}

# 显示该条目下的所有测试内容
function ShowAllTestContent() {
        father_test_case_num=$1
        cur_case_num=${father_test_case_num}

        # 获得当前用例组的名称（用以在页面上展示）
        for test_case in ${test_case_num_list}; do
                ret=$(echo ${test_case} | grep "${father_test_case_num}#" | awk -F'#' '{print $2}')
                if [ -n "$ret" ]; then
                        father_test_case=${ret}
                        cur_test_case_content=${father_test_case_num}
                fi
        done


        # 获取测试用例组内容，并输出
        GetAllTestCaseContentByCaseNum "${father_test_case}"
        center_text=""
        count=1
        for c in ${test_case_content_list}; do
                case_num=$(echo $c | awk -F'#' '{print $1}')
                case_content=$(echo $c | awk -F'#' '{print $2}')
                line="[${count}]\t${case_content}"
                center_text="${center_text}${line}\n"
                count=$((count + 1))
        done


        title="显示测试内容 "
        buttons_name="『退出（Q)』\t\t『下一步（Enter）』\t\t『上一步（R）』"
        bottom_title="> ${father_test_case_num} ${father_test_case}"
        read_input_text="选择测试内容："

        ShowUI "${title}" "${bottom_title}" "${buttons_name}" "${center_text}" "${read_input_text}" 'ShowAllTestContent'
}

# 查询一个记录
function ShowOneTestContent() {
        input=$1

        # 获取到一个测试用例对象
        test_case_content_listArr=(${test_case_content_list})
        case_num=$(echo ${test_case_content_listArr[((input - 1))]} | awk -F'#' '{print $1}')
        case_content=$(echo ${test_case_content_listArr[((input - 1))]} | awk -F'#' '{print $2}')
        cd "$working_dir"
        one=$(cat ${csv_data_file} | tail +3 | grep "${case_num},")

        # 对一行测试用例字符串进行解析
        step="[操作步骤]\n\t"$(echo $one | awk -F',' '{print $5}')"\n"
        expect="[预期结果]\n\t"$(echo $one | awk -F',' '{print $6}')"\n"
        param="[参数列表]\n"
        params['type']=$(echo $one | awk -F',' '{print $7}')
        params['photoType']=$(echo $one | awk -F',' '{print $8}')
        params['start']=$(echo $one | awk -F',' '{print $9}')
        params['end']=$(echo $one | awk -F',' '{print $10}')
        params['PersonId']=$(echo $one | awk -F',' '{printf "%s", $11}')
        # 存进字典中
        for key in ${!params[*]}; do
                param=${param}"\t$key: ${params[$key]}\n"
        done

        bottom_title="> ${father_test_case_num} ${father_test_case} >> ${case_num} ${case_content}"
        center_text="${step}${expect}${param}"

        title="具体接口 "
        buttons_name="『退出（Q)』\t\t『执 行（Enter）』\t\t『上一步（R）』"
        read_input_text="是否开始执行（输入 R 回退）："
        ShowUI "${title}" "${bottom_title}" "${buttons_name}" "${center_text}" "${read_input_text}" 'ShowOneTestContent'
}

# 回调函数，用以处理用户的输入
function Callback() {
        controller_name=$1
        input=$2

                # 处理不用的用户输出
        case "${input}" in
        "q" | "Q")
                exit 0
                return
                ;;
        "r" | "R")
                PrePage ${cur_level}
                return
                ;;
                "")
                                case "${controller_name}" in
                                        "ChangeMqttServerIP" | "ChangeDeviceUUID")
                                                # 直接跳转，不经过后面设置数值的步骤
                                                JumpViewUI "$controller_name" "${input}"
                                                return
                                                ;;
                                        "ShowAllTestCase" | "ShowAllTestContent")
                                                ReloadViewUI "$controller_name" "${cur_test_case_content}"
                                                return
                                                ;;
                                        "ShowOneTestContent")
                                                echo ""
                                                ;;
                                        *)
                                                echo ERR1-Callback
                                                ;;
                                esac
                ;;
        *)
                echo ERR2-Callback
                ;;
        esac

        # 设置 matt server ip  和 device uuid 变量的值
        case "${controller_name}" in
        "ChangeMqttServerIP")
                SaveMqttServerIpToConfigFile ${input}
                ;;
        "ChangeDeviceUUID")
                SaveDeviceUuidToConfigFile ${input}
                ;;
        *)
                echo ERR3-Callback
                ;;
        esac

                # 跳转目录
        JumpViewUI "${controller_name}" "${input}"
}


# 去到上一个页面
function PrePage() {
                cur_level=$((cur_level - 1))
                echo "--------------------------------------------------------------------"
                echo "${nav_controller_name["${cur_level}"]} ${nav_input["${cur_level}"]}"
                ReloadViewUI "${nav_controller_name[${cur_level}]}" "${nav_input[${cur_level}]}"
}


## 跳转 UI 视图
function JumpViewUI() {
        controller_name=$1
        input=$2

        # 未跳转页面之前的 controller 和 input
        nav_controller_name["${cur_level}"]=$1
        nav_input["${cur_level}"]=$2

        # 跳转完成以后 cur_level 需要自增
        cur_level=$((cur_level + 1))

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
        "ShowOneTestContent")
                ExecuteTest
                ;;
        *)
                echo ERR-JumpViewUI
                ;;
        esac
}

# 重新加载 UI 视图
function ReloadViewUI() {
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
        "ShowOneTestContent")
                ShowOneTestContent "${input}"
                ;;
        *)
                echo ERR-ReloadViewUI
                ;;
        esac
}


# --------------------> 数据操作层  <------------------------------------------------------------
ip_regex_pattern='[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'               # 正则表达式匹配 IP 地址
uuid_regex_pattern='device_uuid#[0-9a-zA-Z]+'                   # uuid 正则
test_case_num_list=                                                                             # 测试用例列表
test_case_content_list=                                                                 # 测试内容列表
mqtt_demo_path='/home/test/000/mqtt/bin/x64'                    # 可执行程序（二进制）的目录

csv_data_file="./test_case.csv"                                                 # 数据文件
config_file="${config_path}/${user_uuid}.config"                # 配置文件地址
uuid_pre="${config_path}/${user_uuid}"                                  # 前缀
uniq_test_num_file="${uuid_pre}--uniq_test_num_file"    # 去重后的测试编号
test_case_content="${uuid_pre}--test_case_content"              # 单个测试用例组
temp_file="${uuid_pre}-temp"                                                    # 中转文件


# 从配置文件中获得 mqtt server 的 IP 地址
# 无入参
function getMqttServerIpFromConfigServer() {
        if [ -f ${config_file} ]; then
                mqtt_server_ip=$(cat ${config_file} | grep mqtt_server_ip | awk -F'#' '{print $2}')
        fi
        # 如果配置文件不存在，则不进行任何处理
}

# 设置 mqtt server 的 IP 地址
# 第一个参数：mqtt 服务器地址
# 修改了全局变量：
#       - config_file
function SaveMqttServerIpToConfigFile() {
        # 文件存在则，修改文件中的内容为当前 IP 地址。并更新全局变量 mqtt_server_ip
        # 文件不存在，则新建一个文件
        mqtt_server_ip=$1
        if [ -f ${config_file} ]; then
                sed -i -r "s/${ip_regex_pattern}/${mqtt_server_ip//\./\\.}/g" ${config_file}
        else
                echo 'mqtt_server_ip#'${mqtt_server_ip} >${config_file}
        fi

        # 如果获取不到数值，则将本数值添加到文件中
        _mqtt_server_ip=$(echo ${config_file} | grep mqtt_server_ip | awk -F'#' '{print $2}')
        if [ "_mqtt_server_ip" == "" ]; then
                sed -i -r "s/mqtt_server_ip#[^\n]\+/mqtt_server_ip#${mqtt_server_ip//\./\\.}/g" ${config_file}
        fi
}

## 从配置文件中获得 device uuid 信息
# 无入参
function GetUuidFromConfigFile() {
        if [ -f ${config_file} ]; then
                device_uuid=$(cat ${config_file} | grep device_uuid | awk -F'#' '{print $2}')
        fi
}

# 设置设备 UUID
# 第一个参数：设备uuid
# 修改了全局变量：
#       - config_file
function SaveDeviceUuidToConfigFile() {
        device_uuid=$1
        # 文件存在则，修改文件中的内容为当前 UUID。并更新全局变量 device_uuid
        # 文件不存在，则新建一个文件
        if [ -f ${config_file} ]; then
                sed -i -r "s/${uuid_regex_pattern}/device_uuid#${device_uuid//\./\\.}/g" ${config_file}
        else
                echo 'device_uuid#'${device_uuid} >${config_file}
        fi

        # 如果获取不到数值，则将本数值添加到文件中
        _device_uuid=$(cat ${config_file} | grep device_uuid | awk -F'#' '{print $2}')
        if [ -z "${_device_uuid}" ]; then
                echo 'device_uuid#'${device_uuid} >>${config_file}
        fi
}

# 获得去重后的用例序号
# 无入参
# 修改了全局变量：
#       - temp_file 中转文件，使用命令进行输入流处理的时候，不能编辑输入流。需要中间人
#       - uniq_test_num_file 去重后的测试序号（文件）
#       - test_case_num_list 去重后的用例（列表）
function GetUniqTestNum() {
        cat ${csv_data_file} | tail +3 | awk -F',' '{printf "%s#%s\n", $2,$3}' >${temp_file}
        uniq ${temp_file} >${uniq_test_num_file}        # 使用到 uniq 语句进行去重
        test_case_num_list=$(cat ${uniq_test_num_file})
}

# 通过用例序号，获得一组测试用例
# 第一个参数：用例序号
# 修改了全局变量：
#       - test_case_content 测试用例内容（文件）
#       - test_case_content_list 测试用例内容（列表）
function GetAllTestCaseContentByCaseNum() {
        cat ${csv_data_file} | tail +3 | grep ",$1," | awk -F',' '{printf "%s#%s\n", $1,$4}' >${test_case_content}
        test_case_content_list=$(cat ${test_case_content})
}

# 执行测试
# 无入参
function ExecuteTest() {

        # 修改mqtt服务器和设备uuid的参数
        ChangeConfig "mqtt_ip" "${mqtt_server_ip}"
        ChangeConfig "device_uuid" "${device_uuid}"
        # 修改其他参数（当且仅当参数被用户选择时，才修改参数）
        for key in ${!params[*]}; do
                value=${params[$key]}
                if [ ${#value} -ge 1 ]; then
                        ChangeConfig "${key}" "${value}"
                fi
        done

        # 执行构建命令
        $(
                cd ${mqtt_demo_path}
                make clean
                make
        )

        #开始运行程序
        cur_dir=${PWD}
        cd ${mqtt_demo_path}
        echo -e "执行程序： demo_x64 ${cur_case_num}"
        ./demo_x64 ${cur_case_num}
        cd ${cur_dir}

        PrePage
        echo "###########################"${cur_level}
}

# 修改 main.cpp 中的参数
# 第一个参数：需要修改的变量的名称
# 第二个参数：目标修改的数值
function ChangeConfig() {
        keyword=$1
        value=$2
        pattern=
        target=
        line=

        # 依据传输的关键字，确认 sed 替换语句的模板
        case "$keyword" in
        "mqtt_ip")
                pattern='char \*host = \(char \*\)\"[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\";'
                target='char \*host = \(char \*\)\"'${value//\./\\.}'\";'
                ;;
        "device_uuid")
                pattern='sprintf\(g_uuid,\"%s\",\"[^\"]+\"\);'
                target='sprintf\(g_uuid,\"%s\",\"'${value}'\"\);'
                ;;
        "type")
                pattern='int type = [0-9]'
                target='int type = '${value}
                line='4000,4500'
                ;;
        "photoType")
                pattern='int photoType = [0-9]'
                target='int photoType = '${value}
                line='4250,4750'
                ;;
        "start")
                pattern='int start = [0-9]+'
                target='int start = '${value}
                line='4000,4600'
                ;;
        "end")
                pattern=',end = [0-9]+'
                target=',end = '${value}
                line='4000,4600'
                ;;
        "PersonId")
                pattern='root, \"PersonId\", \"[^\"]+\"'
                target='root, \"PersonId\", \"'${value}'\"'
                line='3250,3750'
                ;;
        *)
                echo "error-ChangeConfig"
                ;;
        esac

        echo "----------------------------"
        echo "『使用到的 sed 语句』"
        echo "sed -i -r '${line}s/${pattern}/${target}/g' ${mqtt_demo_path}/main.cpp"

        # 使用 sed 语句直接修改源文件
        sed -i -r "${line}s/${pattern}/${target}/g" ${mqtt_demo_path}/main.cpp
}


function KillProgram(){
        program_pid=$(ps -ef | grep "demo_x64" | grep -v grep | awk '{print $2}');
        kill  $program_pid;


}

# --------------------> 开始执行  <--------------------
# 检查是否有配置文件路径
if [ -n "${config_path}" ]; then mkdir "${config_path}"; fi
# 入口程序
ChangeMqttServerIP





#X=0
#while :
#do
#  echo "X=$X"
#  X=`expr ${X} + 1`
#  sleep 1
#done
