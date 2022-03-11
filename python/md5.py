'''
使用 Python 进行 md5 加密
'''



import hashlib

data = input("Please input a data string, and then we will use md5 encryption:\n")

result = hashlib.md5(data.encode("utf-8")).hexdigest()
print(result)

input("Please enter any key to kill this program.")
