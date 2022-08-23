import os
import shutil




cur_path = os.path.abspath(".")
base_name = "艺术照-RK商汤"
log_file_name = "艺术照-RK商汤-192.168.1.81.txt"
img_path = cur_path+"\\"+"艺术照-1524张"
total_sucess_times = 0
total_sucess_spend_time = 0
os.mkdir(base_name)






def load_log_file(logfile_path):
    """load the import log file"""
    with open(logfile_path, "r", encoding="GBK") as f:
        line = f.readline();
        while(line != ""):
            parse_one_line(line)
            line = f.readline();

def parse_one_line(line):
    """parse one log line data"""
    line = line.split("   ")[1]
    result_str = line.split(":")[0]
    if result_str == "完成":
        return
    img_name_str = line.split(":")[1].split(", ")[1]
    
    
    clac_success_spend_time(line, result_str)
    
    #开始转移文件
    transfer_img_file(result_str, img_name_str)
    
    

def clac_success_spend_time(line, result_str):
	if result_str.startswith("导入成功"):
		global total_sucess_times, total_sucess_spend_time
		spend_time = line.split(":")[2].split(" ")[1]
		total_sucess_times += 1
		total_sucess_spend_time = total_sucess_spend_time + int(spend_time)
		print("成功次数: " + str(total_sucess_times))
		print("成功耗时: " + str(total_sucess_spend_time))


def transfer_img_file(result_str, img_name_str):
    """transfer all the img file, include success and fail imgs"""
    print(img_name_str)
    
    if not os.path.exists(base_name+"\\"+result_str):
        os.mkdir(base_name+"\\"+result_str)
    shutil.copy(img_path + "\\"+img_name_str, base_name+"\\"+result_str)
    
    
    if result_str.startswith("失败"):
        if not os.path.exists(base_name+"\\"+"失败（全部集合）"):
            os.mkdir(base_name+"\\"+"失败（全部集合）")
        
        shutil.copy(img_path+"\\"+img_name_str, base_name+"\\"+"失败（全部集合）")



if __name__ == '__main__':
    logfile_path = cur_path + "\\" + log_file_name
    load_log_file(logfile_path)


