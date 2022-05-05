from docx import Document
import json


document = Document("D:/0-DesktopData/python-mqtt-client/docx/mqtt.docx")

tables = document.tables


schema_type_dic = {"字符串":"string", "整型": "number", "对象": "object", "数组": "array", "布尔": "boolean", "空": "null"}


def generate_new_xlsx_file(table, count):
    """生成一个新的 xlsx 文件"""

    # 名称	    定义	            必需	长度/范围	    类型	        备注
    # Action	固定“addPerson”	    Y		                字符串	
    
    action = table.cell(1, 0).text
    len_rows = len(table.rows)
    len_columns = len(table.columns)
    
    the_json = json.loads("{}")

    the_json['type'] = 'object'
    the_json['properties'] = {}
    the_json['required'] = []
    required_list = []
    parent_nodes = ["", "", "", "", "", "", "", "", "", ""]

    for i in range(1, len_rows):
        # 获得所有字段
        name = table.cell(i, 0).text
        definition = table.cell(i, 1).text
        required = table.cell(i, 2).text
        restriction = table.cell(i, 3).text
        the_type = table.cell(i, 4).text
        description = table.cell(i, 5).text

        real_name = name.replace('+', '')



        if "数组" in the_type:
            parent_nodes[name.count('+')] = real_name
            if the_type == "JSON数组":
                the_type = "对象"
                the_json['properties'][parent_nodes[0]] = { "type": schema_type_dic[the_type], "title": definition, "description":  description}
                the_json['properties'][parent_nodes[0]]['properties'] = {}
            elif the_type == "JSON字符串数组":
                the_type = "数组"
                #the_json['properties'][parent_nodes[0]] = { "type": schema_type_dic[the_type], "title": definition, "description":  description}
                # the_json['properties'][parent_nodes[0]]['items'] = {"type": "string"}
            elif the_type == "JSON整型数组":
                the_type = "数组"
        else:
            item =  { "type": schema_type_dic[the_type], "title": definition, "description":  description}
            the_json['properties'][name] = item
        # 如果是属于某一个对象中的元素，则进行不同的操作
        if "+" in name:
            item =  { "type": schema_type_dic[the_type], "title": definition, "description":  description}
            # 统计 + 符号的个数，用于计算正在处于第几层。有 1 个说明位于下面一层，有 2 个说明位于下面 2 层
            levels = name.count('+')
            _name = real_name
            # 有多少层，就深入到多少层的 json 语句中去，进行赋值
            if levels == 1:
                print(name)
                print(parent_nodes)
                the_json['properties'][parent_nodes[0]]['properties'][_name] = item


        if required == "Y":
            required_list.append(real_name)

    the_json['required'] = required_list
    print(the_json)





    # print(f'Action: {action},  len_rows: {len_rows},  len_columns: {len_columns}')

tables_count = len(tables)
print(tables_count)

count = 0
for i in range(tables_count):
    if tables[i].cell(1,0).text == "Action" and len(tables[i].columns) == 6:
        count += 1
        generate_new_xlsx_file(tables[i], count)
        break
print(count)

