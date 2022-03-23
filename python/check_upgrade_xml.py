'''
检查一键升级文件（upgrade.xml）中的所有文件是否均存在

注：升级文件一般和 upgrade.xml 文件在同一个目录下

操作步骤：
1. 给定一个目录
2. 将该目录下的文件，均存储在一个列表中
3. 在列表中，查找是否存在 xml 文件
4. 如果存在多个，则循环进行 5 及其以后的动作
5. 存在一个 upgrade_XXX.xml 文件
6. 解析该 xml 文件结构，并得到其中所有的升级文件名称
7. 遍历升级文件名称，检查是否存在于当前目录文件列表中
8. 如果文件不存在当前列表中，则在屏幕上输出该文件名称
9. 所有文件均能找到，输出成功
10. 存在文件无法找到的，则输出失败（无法找到的文件，在之前已经输出了）

预期的 UI 效果：
----------------------------------------（"-"*40）
当前目录（xxx）中
存在 xxx 个 xml 文件，分别是：
upgrade_1.xml 
upgrade_2.xml

正在解析 upgrade_1.xml 文件
 ------
| PASS |
 -----

正在解析 upgrade_2.xml 文件
[WARN]: xxx_111_.uot 文件不存在
 ------
| FAIL |
 ------

----------------------------------------


问题：
如果给定的是一个多层的文件夹，并且只有第二层的三个文件夹中才有 upgrade.xml 文件，怎么办？
- 对每一个文件夹，进行同样的操作即可



需要的知识储备：
1 读取文件夹下的所有文件
2 查找列表中以某个特定后缀结尾的文件
3 解析 xml 文件
4 遍历文件夹、循环


'''





import os
import xml.etree.ElementTree as ET

# 定义几个后续会用到的函数
def printDivider():
    ''' 画分割线 '''
    print("-"*40)

def printPASS():
    ''' 画 PASS '''
    print(" ------")
    print("| PASS | 成功")
    print(" ------")
    print("")

def printFAIL():
    ''' 画 FAIL '''
    print(" ------")
    print("| FAIL | 失败！！！")
    print(" ------")
    print("")

def analyzeXmlFile(path, xml_file, files):
    print(upgrade_file_path)
    #print(path)
    ''' 解析 xml 文件'''
    tree = ET.parse(path + "\\" + xml_file)
    root = tree.getroot()
    #file_nodes = root.find("File")
    #print(root.tag)
    #print(len(file_nodes))
    is_ok = 1
    for node in root:
        file_name = node.get("Name")

        # 默认设定文件是不存在的
        is_file_exist = 0
        for file in files:
            #print(str(file))
            if file_name == file:
                is_file_exist = 1
        if is_file_exist == 0:
            print("[WARN]: " + file_name + " 文件不存在!")
            is_ok = 0

    if is_ok == 1:
        printPASS()
    else:
        printFAIL()


def do_something(path):
    # 2 列出目录下的所有文件
    files = os.listdir(path)

    # 3 找到所有的 xml 文件
    xml_files = []
    for file in files:
        if file.endswith(".xml"):
            xml_files.append(file)


    printDivider()
    print("当前目录中（" + path +"）")
    print("存在 " + str(len(xml_files)) + " 个 xml 文件，分别是：")
    for xml_file in xml_files:
        print(xml_file)
    print("")

    for xml_file in xml_files:
        print("正在解析 " + xml_file +" 文件")
        #print(path)
        analyzeXmlFile(path, xml_file, files)

    printDivider()


# 遍历该目录
def iterDir(path):
    if os.path.isdir(path):
        do_something(path)
        files = os.listdir(path)
        for file in files:
            new_path = path + "\\" + file
            if os.path.isdir(new_path):
                iterDir(new_path)


# 1 给定一个目录
upgrade_file_path = input("请将升级包文件夹拖入到窗口中：\n")
upgrade_file_path = "D:\\3-Data\\Desktop\\JVT_WORK\\[√]\\2022-3-15"

iterDir(upgrade_file_path)
