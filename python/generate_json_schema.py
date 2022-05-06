from docx import Document
import json
import os


document = Document("D:/0-DesktopData/python-mqtt-client/docx/mqtt.docx")

tables = document.tables


schema_type_dic = {"字符串":"string", "整型": "integer", "对象": "object", "数组": "array", "布尔": "boolean", "空": "null", "浮点型": "number"}


def get_cur_parent_node(the_json, level, parent_nodes):
    '''获得当前父级节点'''
    if level == 0:
        return the_json
    elif level == 1:
        return the_json['properties'][parent_nodes[0]]
    elif level == 2:
        return the_json['properties'][parent_nodes[0]]['properties'][parent_nodes[1]]
    elif level == 3:
        return the_json['properties'][parent_nodes[0]]['properties'][parent_nodes[1]]['properties'][parent_nodes[2]]
    else:
        return "false"



def deal_with(i, table, the_json, level, parent_nodes):
    '''处理数据'''

    name = table.cell(i, 0).text
    real_name = name.replace('+', '')
    definition = table.cell(i, 1).text
    required = table.cell(i, 2).text
    restriction = table.cell(i, 3).text
    the_type = table.cell(i, 4).text.replace(' ', '')
    description = table.cell(i, 5).text


    print("---------------------------------------------------------------------------------------------------------------")
    # print(the_json['required'])
    print(real_name + " - " + str(level))
    print(parent_nodes)
    cur_parent_node = get_cur_parent_node(the_json, level, parent_nodes)



    msg = ""
    if restriction != "":
        msg = "取值范围：" + restriction +  "；"
    if description != "":
        msg += description


    if the_type == "JSON对象":
        the_type = "对象"
        # ！！！ 设置了父级节点
        parent_nodes[level] = real_name
        # print("--------> 2 <-------")
        cur_parent_node['properties'][real_name] = { "type": schema_type_dic[the_type], "title": definition, "description":  msg}
        cur_parent_node['properties'][real_name]['properties'] = {}
        cur_parent_node['properties'][real_name]['required'] = []
    
    elif the_type == "JSON数组":
        # 这里其实是一个 json 对象数组
        the_type = "数组"
        # ！！！ 设置了父级节点
        parent_nodes[level] = real_name
        cur_parent_node['properties'][real_name] = { "type": schema_type_dic[the_type], "title": definition, "description":  msg}
        cur_parent_node['properties'][real_name]['items'] = {"type": "object"}
        cur_parent_node['properties'][real_name]['items']['properties'] = {}
        cur_parent_node['properties'][real_name]['items']['required'] = []

    
    elif the_type == "JSON字符串数组":
        the_type = "数组"
        cur_parent_node['properties'][real_name] = { "type": schema_type_dic[the_type], "title": definition, "description":  msg}
        cur_parent_node['properties'][real_name]['items'] = {"type": "string"}
    elif the_type == "JSON整型数组":
        the_type = "数组"
        cur_parent_node['properties'][real_name] = { "type": schema_type_dic[the_type], "title": definition, "description":  msg}
        cur_parent_node['properties'][real_name]['items'] = {"type": "number"}
    else:
        cur_parent_node['properties'][real_name] = { "type": schema_type_dic[the_type], "title": definition, "description":  msg}

    if required == "Y":
        required_list = cur_parent_node['required']
        required_list.append(real_name)
        cur_parent_node['required'] = required_list
        print("##################################")
        print(cur_parent_node['required'])

def generate_new_xlsx_file(table, num):
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
    parent_nodes = ["", "", "", "", "", "", "", "", "", ""]

    for i in range(1, len_rows):
        name = table.cell(i, 0).text
        real_name = name.replace('+', '')
        required = table.cell(i, 2).text
        # 层级。值为 0 时代表顶层，值为 1 时代表子第一层
        level = name.count('+')

        if name != "":
            deal_with(i, table, the_json, level, parent_nodes)


    action_name = table.cell(1, 1).text
    print(the_json)
    write_json_schema_file(num, action_name, the_json)


def write_json_schema_file(num, action_name, the_json):
    ''' 写入文件 '''
    with open("json_schema_collections/"+str(num)+"_"+action_name+".json","w") as f:
        json.dump(the_json,f)

if not os.path.exists('json_schema_collections'):
    os.mkdir('json_schema_collections')


tables_count = len(tables)
print(tables_count)

count = 0
for i in range(tables_count):
    if tables[i].cell(1,0).text == "Action" and len(tables[i].columns) == 6:
        count += 1
        generate_new_xlsx_file(tables[i], count)
        # break
print(count)

