let utils = {
    CheckDiff (expectJSON, newJSON, JSONPath){
        if (!expectJSON || !newJSON || this.isEmptyObject(expectJSON) || this.isEmptyObject(newJSON))
            return;
        for (let k in expectJSON){
            let curJSONPath = JSONPath + "." + k;
            if (this.getTypeByObj(expectJSON[k]) === 'Array' || this.getTypeByObj(expectJSON[k]) === 'Object')
                this.CheckDiff(expectJSON[k], newJSON[k], this.getTypeByObj(expectJSON) === 'Array' ? JSONPath+"["+k+"]":curJSONPath);
            else if (this.getTypeByObj(expectJSON[k]) !== this.getTypeByObj(newJSON[k]))
                console.log("***[DiffType]*** JSONPath: %s \t Expect Value: %s \t Got: %s", curJSONPath, expectJSON[k], newJSON[k]);
            else if (expectJSON[k] !== newJSON[k])
                console.log("***[DiffValue]*** JSONPath: %s \t Expect Value: %s \t Got: %s", curJSONPath, expectJSON[k], newJSON[k]);
            else
                console.log("[Same] JSONPath: %s    Expect Value: %s    Got: %s", curJSONPath, expectJSON[k], newJSON[k]);
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


// JSONPath介绍：https://www.apifox.cn/help/reference/json-path/
// 测试用例
/**
 * 1. 新json中字段值发生改变
 *  - [√] 值类型不变，内容发生改变
 *  - 值类型发生改变
 *      - [√] int变成str
 *      - int变成其他对象object或array
 * 2. [x] 新json中有老json中没有的字段
 * 3. [√] 新json中没有老json中有的字段
 * 4. 字段位置发生改变
 *  - [√] 层级
 *  - [√] 同一层的顺序
 * 5. 发生改变的字段的类型
 *  - [√] int
 *  - [√] string
 *  - [√] object
 *  - [√] array
 *  - null
 */







jsonStr1 =  `
{
    "store": {
        "book": [{
                "category": "reference",
                "author": "Nigel Rees",
                "title": "Sayings of the Century",
                "price": 8.95
            }, {
                "category": "fiction",
                "author": "Evelyn Waugh",
                "title": "Sword of Honour",
                "price": 12.99
            }, {
                "category": "fiction",
                "author": "Herman Melville",
                "title": "Moby Dick",
                "isbn": "0-553-21311-3",
                "price": 8.99
            }, {
                "category": "fiction",
                "author": "J. R. R. Tolkien",
                "title": "The Lord of the Rings",
                "isbn": "0-395-19395-8",
                "price": null
            }
        ],
        "bicycle": {
            "color": "red",
            "price": 19.95
        }
    }
}
`
jsonStr2 = `
{
    "store": {
        "book": [{
                "category": "reference",
                "author": "Nigel Rees",
                "title": "Sayings of the Century",
                "price": 8.95
            }, {
                "category": "fiction",
                "author": "Evelyn Waugh",
                "title": "Sword of Honour",
                "price": 12.99
            }, {
                "category": "fiction",
                "author": "Herman Melville",
                "isbn": "0-553-21311-3",
                "price": 8.99
            }, {
                "category": "fiction",
                "author": "J. R. R. Tolkien",
                "title": "The Lord of the Rings",
                "isbn": "0-395-19395-8",
                "price": null
            }
        ],
        "bicycle": {
            "color": "red",
            "price": 19.95
        }
    }
}
`



utils.CheckDiff(JSON.parse(jsonStr1), JSON.parse(jsonStr2), "$")
