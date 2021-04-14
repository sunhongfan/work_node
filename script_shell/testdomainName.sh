#!bin/bash


echo -e "网站名称\t网站域名\t是否具有AAAA记录\t解析是否需要www\t网站IPv6地址\t首页是否支持IPv6可访问\tIPv6状态代码" >> target.txt
echo -e "网站名称\t网站域名\t是否具有AAAA记录\t解析是否需要www\t网站IPv6地址\t首页是否支持IPv6可访问\tIPv6状态代码" 
# 定义dns服务器


# 网站是否具有4A记录

web4a(){
	recode4a=`dig aaaa  $weburl @114.114.114.114 +short | grep  '^[0-9]' | head -n 1`
    if [ -n "$recode4a" ]; then
        str4a="有"
        addwww="不需要"
    else
        
	recode4a=`dig aaaa  "www.$weburl" @114.114.114.114 +short | grep  '^[0-9]' | head -n 1` 
        if [ -n "$recode4a" ]; then
            str4a="有"
            addwww="需要"
        else
            str4a="没有"
        fi
    fi

}

#获取状态码，并测试连通性
testurl(){

    
    if [[ ${addwww} == "需要" ]];then
        status_code=$(curl -6 -L -m 10 -o /dev/null -s -w %{http_code} "www.$weburl")
        status_codes=$(curl -6 -L -m 10 -o /dev/null -s -w %{http_code} "https://www.$weburl")
    else
        addwww="不需要"        
        status_code=$(curl -6 -L  -m 10 -o /dev/null -s -w %{http_code} "$weburl")
        status_codes=$(curl -6 -L  -m 10 -o /dev/null -s -w %{http_code} "https://$weburl") 
    fi

    if [ "$status_code" == "200" ] || [ "$status_codes" == "200" ];then
        statusIPv6Access="支持"
    else
        statusIPv6Access="不支持"
    fi
}





# 数据处理主体
count=0
filecount=`cat source.txt | wc -l`
while read line
do

###### 网站名称 网站域名 ########

    weburl=$(echo ${line#*//} | cut -d "/" -f1)
    sitename=$(echo $line | awk '{print $1}')

    web4a
    testurl   
	
    echo -e "$sitename\t$weburl\t$str4a\t$addwww\t$recode4a\t$statusIPv6Access\t$status_code  $status_codes">>target.txt 
    echo -e "$sitename\t$weburl\t$str4a\t$addwww\t$recode4a\t$statusIPv6Access\t$status_code  $status_codes"

    count=$((count+1))

done < "source.txt"

if [[ "$count" -eq "$filecount" ]]; then
	echo "数据处理完成！"
	exit 0
else
	echo "数据处理不完整,缺失某行数据"
	exit 100	
fi
