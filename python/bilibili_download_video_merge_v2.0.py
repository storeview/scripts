import os
import json


def merge_video(sub_directory, cur_path):
    """ 合并视频 """
    print(sub_directory)
    #print(cur_path)
    with open(sub_directory + "\\" + "entry.json", "rb") as entry_json:
        entry = json.load(entry_json)
        tmp_dir = ""
        # 是多 P 视频
        if os.path.exists(sub_directory+"\\64\\"):
            tmp_dir = sub_directory + "\\64\\"
        # 可能是电影
        if os.path.exists(sub_directory+"\\80\\"):
            tmp_dir = sub_directory + "\\80\\"
        
        mp4_name = entry["title"]
        page = ""
        if "ep" in entry:
            mp4_name = entry["ep"]["index_title"]
            page = entry["ep"]["index"] + "__"
        if "page_data" in entry:
            mp4_name = entry["page_data"]["part"]
            page = str(entry["page_data"]["page"]) + "__"


        video_m4s_path = '"{parent_path}video.m4s"'.format(parent_path=tmp_dir)
        audio_m4s_path = '"{parent_path}audio.m4s"'.format(parent_path=tmp_dir)
        new_mp4_dir_path = "{cur_path}\\{title}".format(cur_path=cur_path, title=entry["title"])
        # 创建存储播放好的视频路径
        if not os.path.exists(new_mp4_dir_path):
            os.makedirs(new_mp4_dir_path)
        new_mp4_path = '"{new_mp4_dir_path}\\{page}{mp4_name}.mp4"'.format(new_mp4_dir_path=new_mp4_dir_path, page=page, mp4_name=mp4_name)

        command = "ffmpeg -i {video} -i {audio} -c:v copy -c:a copy {new_mp4} -loglevel quiet -n".format(video=video_m4s_path, audio=audio_m4s_path, new_mp4=new_mp4_path)

        print("开始转换视频："+mp4_name)
        print(command)
        os.system(command)
        print("-->转换完成<--")


def transform(path, cur_path):
    """ 开始转换 """
    print("\n--------------------")
    #print(path)
    files = os.listdir(path)
    for file in files:
        sub_directory = path + "\\" + file
        merge_video(sub_directory, cur_path)
    print("------------------\n")




# 1. 将手机上缓存的 Bilibili 视频传输到电脑上
#    - 目前 Bilibili 上下载的视频，一般存储在下面目录下（安卓）：内部存储设备\Android\data\tv.danmaku.bili\download
#    - 并且文件夹以数字命名的方式，组织下载的各个视频
#    - 通过一定方式将手机中下载的视频，移动到电脑中
mode = input("One Video or Many Video?  1. one    2. many\n")
path = input("Please enter the bilibili download video main directory path\n")
cur_path = os.getcwd()
if mode == "1":
    transform(path, cur_path)
elif mode == "2":
    files = os.listdir(path)
    for file in files:
        transform(path+"\\"+file, cur_path)
