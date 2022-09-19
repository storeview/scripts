# 设置需要循环的次数
n = 542





#URL批量添加人员
raw_str = '{"Action":"batchAddPerson","TaskID":"811","PhotoType":0,"PersonTotal":80,"PersonInfo":[###{"OperateType":0,"PersonCover":1,"PersonType":2,"PersonId":"${1+n}","PersonName":"user${1+n}","PersonIdentity":1,"Sex":1,"PersonPhotoURL":"http://128.128.12.70:8881/${1+n}.jpg"},###]}'




#使用方法
#1.将需要生成重复内容的 json 语句，全部通过工具压缩到一行
#2.使用 ### ### 将需要重复生成的json语句圈定起来
#3.在需要设置自增量的地方，使用句子${1+n}
#4.将最后生成的语句复制到网页中即可



raw_str_splits = raw_str.split("###")
A = raw_str_splits[0]
B = raw_str_splits[1]
C = raw_str_splits[2]


# 在循环过程中，读取变量，并进行替换
import re

def _deal(matched):
    var = matched.group(1)
    var = var.replace('n', str(index))
    splits = var.split('+')
    return str(int(splits[0])+int(splits[1]))


tmp_str = ""
index = 0
for i in range(0, n):
    index = i
    tmp_str += re.sub(r'\$\{([n+0-9]+)\}', _deal, B)
    
    
# 拼接子串
print(A+tmp_str+C)
    