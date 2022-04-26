// Apifox、Postman 脚本

// 判断返回的 JSON 消息中，没有重复的 key
// 简单的判断一下（前提条件：rawData没有格式）
pm.test("JSON 没有重复的字段（Key），即内置 JSON.parse() 解析前后，字符串数据没有变化", function () {
    // 获得原始数据
    var rawData = pm.response.text()
    // 使用 js 内置的 parse 方法解析原始数据为 json 对象，然后再转换为字符串
    var rawDataAfterJsonParse = JSON.stringify(JSON.parse(rawData))
  
    // console.log(rawData)
    // console.log(rawDataAfterJsonParse)
  
    // 期间因为，内置函数 JSON.parse() 会将重复的字段自动剔除，所以
    // 一旦出现重复字段，两次字符串的将会不同，从而报错
    pm.expect(rawData).to.include(rawDataAfterJsonParse);
  });
  
  // 使用下列网站验证 JSON 中是否有重复的 KEY
  
  // http://ohjson.cn/
  
  // 二次确认！第一遍为此自动脚本确认