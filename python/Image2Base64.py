'''
图片转 Base64 编码
'''

import base64

img_path = input("Please drag a jpg/png file to this window, and then we will use base64 to encode it\n")

with open(img_path, "rb") as f:
    base64_data = base64.b64encode(f.read())
    print(str(base64_data))


input("Just paste...")
