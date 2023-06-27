import os
import json


"""
哔哩哔哩下载的视频合并
将手机上缓存的 Bilibili 视频传输到电脑上

背景:
- 目前 Bilibili 上下载的视频，一般存储在下面目录下（安卓）：内部存储设备\Android\data\tv.danmaku.bili\download
- 并且文件夹以数字命名的方式，组织下载的各个视频

使用方式:
1. 将手机上download目录下的所有视频, 移动到电脑上(例如A目录).
2. 将目录作为参数传递给此脚本(例如A目录), 然后执行脚本.
"""
def main():
    #1.获取视频目录, 和当前程序所在目录.
    video_path = input("Please enter the bilibili download video main directory path\n")
    cur_path = os.getcwd()
    
    #2.确定给定的视频目录参数的情况.(1 最上层目录   2 电影目录   3 电视剧目录   4 啥也不是)
    directory_type = get_directory_type(video_path)
    print("--------------------> directory_type: {} <--------------------".format(directory_type))
    
    #3.开始转换视频
    start_transform(video_path, cur_path, directory_type)

def get_directory_type(video_path):
    for f1 in os.listdir(video_path):
        for f2 in os.listdir(os.path.join(video_path, f1)):
            #第二层目录中, 包含16, 代表当前目录是电视剧目录.
            if f2 == "16" or f2 == "64":
                return 3
            #包含80, 代表当前目录是电影目录.
            elif f2 == "80":
                return 2
            #在第三层目录中, 如果包含 entry.json, 则说明该目录是最上层目录.
            for f3 in os.listdir(os.path.join(video_path, f1, f2)):
                if f3 == "entry.json":
                    return 1
    return 4

def start_transform(video_path, cur_path, directory_type):
    if directory_type == 4:
        return
    #如果是最顶层目录, 则递归下面的每一个文件夹, 获取文件夹的类型, 并执行相关指令.
    if directory_type == 1:
        for file in os.listdir(video_path):
            start_transform(os.path.join(video_path, file), cur_path, get_directory_type(os.path.join(video_path, file)))
    #对于电影和电视剧, 都是一样. 遍历所有文件夹, 然后将文件夹中的视频和entry.json信息进行合并.
    else:
        for file in os.listdir(video_path):
            merge_video(video_path+"\\"+file, cur_path, False)
    
def merge_video(sub_directory, cur_path, update_title):
    """ 合并视频 """
    if os.path.exists(sub_directory + "\\" + "entry.json") == False:
        print("--------------------> Not exists <--------------------")
        print(sub_directory + "\\" + "entry.json")
        return 

    with open(sub_directory + "\\" + "entry.json", "rb") as entry_json:
        #存储视频和音频文件的目录
        tmp_dir = sub_directory
        for file in os.listdir(sub_directory):
            if os.path.isdir(sub_directory+"\\"+file):
                tmp_dir = sub_directory + "\\" + file
                break

        #解析entry.json文件中json字段
        entry = json.load(entry_json)
        #视频标题
        mp4_name = entry["title"]
        #级数
        page = ""
        #第几季
        if "ep" in entry:
            if update_title:
                mp4_name += entry["ep"]["index_title"]
            page = "__" + entry["ep"]["index"].zfill(3)
        #第几集
        if "page_data" in entry:
            if update_title:
                mp4_name += entry["page_data"]["part"]
            page = "__" + str(entry["page_data"]["page"]).zfill(3)


        video_m4s_path = '"{parent_path}\\video.m4s"'.format(parent_path=tmp_dir)
        audio_m4s_path = '"{parent_path}\\audio.m4s"'.format(parent_path=tmp_dir)
        new_mp4_dir_path = "{cur_path}\\{title}".format(cur_path=cur_path, title=mp4_name)
        
        # 创建存储播放好的视频路径
        if not os.path.exists(new_mp4_dir_path):
            os.makedirs(new_mp4_dir_path)

        new_mp4_path = '"{new_mp4_dir_path}\\{title}{page}.mp4"'.format(new_mp4_dir_path=new_mp4_dir_path, title=mp4_name, page=page)

        command = "ffmpeg -i {video} -i {audio} -c:v copy -c:a copy {new_mp4} -loglevel quiet -n".format(video=video_m4s_path, audio=audio_m4s_path, new_mp4=new_mp4_path)

        print("开始转换视频："+mp4_name+page)
        #print(command)
        os.system(command)
        print("-->转换完成<--")



if __name__ == "__main__":
    main()