# 自动提取 Hecaiyun-WebDav 的浏览器中的 Cookie 的变量


# 将自己的 cookie 复制在下面即可，脚本会自行提取变量
cookies='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

# 提取变量的函数
function getValue(){
        echo $cookies | sed -n "s/^.*$1=\(\S*\);.*$/\1/p"
}


# --------------------> 提取变量 <--------------------
# 网页版和彩云Cookie中的 ORCHES-C-ACCOUNT 字段
account=$(getValue "ORCHES-C-ACCOUNT")

# Cookie中的 ORCHES-C-TOKEN
token=$(getValue "ORCHES-C-TOKEN")

# Cookie中的 ORCHES-I-ACCOUNT-ENCRYPT
encrypt=$(getValue "ORCHES-I-ACCOUNT-ENCRYPT")


# --------------------> 填写下列参数 <--------------------
# caiyun.tel： 和彩云的注册号码（需要自行修改）
tel=xxxxxxxxxxx
# caiyun.auth.user-name：可选 默认admin
# caiyun.auth.password：可选 默认admin

# --------------------> 执行该 jar 包 <--------------------
java -jar caiyun-webdav.jar \
        --caiyun.account="${account}" \
        --caiyun.token="${token}" \
        --caiyun.encrypt="${encrypt}" \
        --caiyun.tel="${tel}"