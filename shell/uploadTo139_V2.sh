# 使用 7z 压缩 Store 目录下的文件或文件夹, 命名方式 StoreView序号, 密码 storeview


# Get origin file name from Store/xxx
filenames=$(ls Store | grep -v nohup)
for file in $filenames; 
do 
(
# Print movie name
echo $file

# Get 7z filename from nohup.txt's LAST LINE.
filename=StoreView$(tail nohup.txt -n1 | sed 's/StoreView//' | awk -F: '{print $1+1}')

# Update ./Store/nohup.txt
rm ./Store/nohup.txt
cp ./nohup.txt ./Store/nohup.txt

# Start Compress
#7z a $file ./Store/*  -mx0 -mhe=on -pstoreview -v5120m
7z a $filename -mx0 -mhe=on -pstoreview -bsp1 -v5120m ./Store/$file ./Store/nohup.txt  

# Update nohup.txt
echo "${filename}: ${file}" >> nohup.txt

# Delete file
rm ./Store/$file -rf
); 
done
