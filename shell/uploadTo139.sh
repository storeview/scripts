# 压缩并上传文件到云盘

filename=$1



movie_name=$(ls Store | grep -v nohup)



7z a $filename ./Store/* -x!*.jar -mx0 -mhe=on -pstoreview -v5120m



for ff in $(ls *7z*) 
do 
	
	echo $ff
	curl --user admin:admin -T ${ff} http://localhost:8080 -o /dev/stdout
done


echo "${filename}: ${movie_name}" >> nohup.txt
