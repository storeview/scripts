with open("D:\\Windows数据移动到此文件夹\\Desktop\\15.csv", "r") as f:
	for line in f:
		for time in line.strip().split(","):
		args = time.strip().split(" ")
		print(args[2]+"/"+args[1].replace("月","")+"/"+args[0]+" "+args[3], end=",")
		print()