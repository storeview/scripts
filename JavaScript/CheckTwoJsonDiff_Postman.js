//前置脚本
// 设置预期的 json 的字符串
let expect =  `
{
    "Name": "getMQTTParametersResponse",
    "Data": {
        "Enabled": 1,
        "Address": "128.128.12.70",
        "Port": "1883",
        "UserName": "",
        "Password": "",
        "Topic": "",
        "HeartbeatInterval": 13,
        "ResendEnabled": 0,
        "SendRecord": 1,
        "CutomizedTopic": ""
    },
    "Code": 1,
    "Message": ""
}
`


// 设置环境变量，提供给整个文件夹的后置脚本使用
let expectJson = JSON.stringify(JSON.parse(expect));
pm.environment.set("expectJson",expectJson);
console.log(pm.environment.get("expectJson"))




// 后置脚本
let utils = {
    CheckDiff (expectJSON, newJSON, JSONPath){
        if (!expectJSON || !newJSON || this.isEmptyObject(expectJSON) || this.isEmptyObject(newJSON))
            return;
        for (let k in expectJSON){
            let curJSONPath = JSONPath + "." + k;
            if (this.getTypeByObj(expectJSON[k]) === 'Array' || this.getTypeByObj(expectJSON[k]) === 'Object')
                this.CheckDiff(expectJSON[k], newJSON[k], this.getTypeByObj(expectJSON) === 'Array' ? JSONPath+"["+k+"]":curJSONPath);
            else {
                let testName = `${curJSONPath} 值为 ${expectJSON[k]}`;
                pm.test(testName, ()=>{
                    pm.expect(newJSON[k]).to.eql(expectJSON[k]);
                })
            }
        }
    },
    getTypeByObj(obj) {
        return Object.prototype.toString.call(obj).match(/^\[object ([a-zA-Z]*)\]$/)[1];
    },
    isEmptyObject(obj) {
        for (let key in obj) {
            return false;
        };
        return true;
    }
}

let expectJson = pm.environment.get("expectJson");
pm.environment.set("expectJson",null);

let resJson = JSON.stringify(pm.response.json());

if (!expectJson)
    console.log("【比较两个JSON语句是否完全一样】未获取到值（expectJson：%s \t resJson：%s", expectJson, resJson)

utils.CheckDiff(JSON.parse(expectJson), JSON.parse(resJson), "$")
