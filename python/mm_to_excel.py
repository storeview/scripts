import xml.etree.ElementTree as ET
import re
from openpyxl import Workbook
from openpyxl.styles import Alignment,Border, Side


"""
v1.0.3


2022-1-19 添加新的功能，生成的 excel 文件，需要放置在 mm 同级目录下、

2022-2-25 将表格中的所有字段用 boarder 框起来
"""

# 使用文件作为解析对象
print("#"*60)
freeplane_filename = input("请输入需要转换的 Freeplane 文件路径（或将文件拖入窗口中）:\n").replace('"','')
tree = ET.parse(freeplane_filename)

# 获得根节点
root = tree.getroot()
# Freeplane思维导图软件的根节点标签是 <map>
# root.tag

print("#"*60)
sheet_name = input("请输入测试用例生成的开始节点（该节点将作为工作蒲sheet的表名，下一级将作为【测试主模块】，若不输入任何值则以思维导图的根节点为起点）:\n")
# 选择测试用例生成的节点，该节点的下一级将作为【测试主模块】，该节点的名称将作为工作蒲 sheet 的表名
    #|-指定节点
    #|__test_main_module
    #|____test_module
    #|______test_content
    #|________test_step(or pre_condition or test_remark)
    #|__________expect_result


#print("------> " + root.tag)
# 获得该节点
top_node = root.find(".//node[@TEXT='"+sheet_name+"']")
# 如果获取不到值，说明 sheet_name 为空或者输入的节点名称不存在，此时应该将根节点作为默认值
if top_node == None:
    top_node = root.find("./node[@TEXT]")



# 新建工作蒲
wb = Workbook()
sheet = wb.active
sheet.title = top_node.get("TEXT")

# 设置表格样式（列宽、表头）
sheet.column_dimensions['A'].width=5
sheet.column_dimensions['B'].width=20
sheet.column_dimensions['C'].width=20
sheet.column_dimensions['D'].width=20
sheet.column_dimensions['E'].width=30
sheet.column_dimensions['F'].width=40
sheet.column_dimensions['G'].width=20
sheet.append(["编号", "测试主模块", "测试模块", "测试内容", "前置条件", "测试步骤", "预期结果", "备注", "测试结果", "异常情况说明"])


# 下面部分的代码可以进一步优化
test_main_model_str = ""
test_model_str = ""
test_content_str = ""
pre_condition_str = ""
test_remark_str = ""
test_step_str = ""
expect_result_str = ""
def addNewNode():
                    print("######################################")
                    print(test_remark_str)
                    sheet.append([i, test_main_model_str.strip(), test_model_str.strip(), test_content_str.strip(), pre_condition_str.strip(), test_step_str.strip(), expect_result_str.strip(), test_remark_str.strip()])


i = 1
for test_main_module in top_node:
    if test_main_module.tag != "node":
        continue
    test_main_model_str = test_main_module.get("TEXT")
    if len(test_main_module) == 0:
        addNewNode()
    for test_module in test_main_module:
        test_model_str = test_module.get("TEXT")
        if len(test_module) == 0:
            addNewNode()
        print("-----> " + test_model_str)
        for test_content in test_module:
            test_content_str = test_content.gete"TEXT")[3:]
            # 如果这一行保存了，请检查 tc:xxx 的末尾是不是粗体
            if len(test_content) == 0:
                addNewNode()
            print("----------> " + test_content_str)
            for test_step in test_content:
                test_step_str = test_step.get("TEXT")
                print(test_step_str)
                if test_step_str[0:2] == "tp":
                    pre_condition_str = test_step_str[3:]
                    test_step_str = ""
                elif test_step_str[0:2] == "tr":
                    print("-------------------->  <--------------------")
                    test_remark_str = test_step_str[3:]
                    print(test_remark_str)
                    test_step_str = ""
                elif test_step_str[0:2] == "ts":
                    test_step_str = test_step_str[3:]
                elif len(test_step) == 0:
                    addNewNode()
                    pre_condition_str = ""
                    test_remark_str = ""
                for expect_result in test_step:
                    expect_result_str = expect_result.get("TEXT")
                    print("###>"+expect_result_str+"<###")
                    addNewNode()
                    pre_condition_str = ""
                    test_remark_str = ""

                    i+=1
                expect_result_str = ""
            test_step_str = ""
            pre_condition_str = ""
            test_remark_str = ""
        test_content_str = ""
    test_model_str = ""
test_main_model_str = ""
                    



    
                    

# 表格生成完成，进行格式处理
thin = Side(border_style="thin", color="000000")
i = 1
# 对所有单元格进行处理
while sheet.cell(i, 1).value != None:
    for j in range(1, 11):
        # 上下左右居中对齐，自动换行
        sheet.cell(i, j).alignment = Alignment(horizontal='center', vertical='center', wrapText=True)
        if j == 5 or j == 6 or j == 7 or j == 8:
            sheet.cell(i, j).alignment = Alignment(horizontal='left', vertical='top', wrapText=True)
        sheet.cell(i, j).border = Border(top=thin, left=thin, right=thin, bottom=thin)
    i += 1


# 对6列的表格进行相邻行内容相同归并处理
for col in range (2, 5):
    row = 2
    start_row = 2
    end_row = start_row
    start_value = sheet.cell(row, col).value 
    if start_value == None or start_value == "":
        continue
    while sheet.cell(row+1, col).value != None:
        if sheet.cell(row + 1, col).value == start_value:
            end_row = row + 1
        else:
            sheet.merge_cells(start_row=start_row, start_column=col, end_row=end_row, end_column=col)
            start_row = row + 1
            end_row = start_row
            start_value = sheet.cell(start_row, col).value
        row += 1
    sheet.merge_cells(start_row=start_row, start_column=col, end_row=end_row, end_column=col)


# 需要使用正则表达式，匹配文件名，并复制给新文件
m = re.search(r'^(.*)\\([^\\]+).mm$',freeplane_filename)
file_parent_dir = m.group(1)
filename = m.group(2)

wb.save(file_parent_dir + "\\temp_"+filename+".xlsx")   

print("#"*60)
print("OK")
