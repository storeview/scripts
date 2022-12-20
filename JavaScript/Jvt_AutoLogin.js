// 自动登录 JVT 设备网页的一个脚本
/**
 * 程序逻辑
 * 1. 通过网页标题 "IP Camera" 确认是自家的设备, 通过地址栏 login 确认是登录界面
 * 2. 找到用户名输入框, 找到密码输入框, 找到登录框
 * 3. 分情况讨论
 *  3.1 如果用户名和密码框都已经有值.
 *      点击登录
 *  3.2 如果用户名有值.
 *      遍历输入可能的密码, 点击登录
 *  3.3 如果用户名为空.
 *      遍历输入可能的用户名, 遍历输入可能的密码, 点击登录
 *  3.4 如果存在"记住密码"的选择框.
 *      勾选该选择框   
 *  3.5 用户名密码正确
 *      进入index界面, 不做处理
 *  3.6 用户名密码错误
 *      有弹框, 处理掉弹框, 继续进行登录操作.
 */



// 油猴脚本
// ==UserScript==
// @name         JVT 网页自动登录脚本
// @match        http://*
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  try to take over the world!
// @author       You
// @grant        none
// ==/UserScript==

(function() {
    'JVT 网页自动登录脚本';

    // Your code here...
    window.onload = function(){
        // 可能的用户名
        let usernames = ['admin']
        // 可能的密码
        let passwords = ['QWkba92123', 'admin', 'admin123', 'admin.123']

        // query selector 路径
        var usernameFieldSelectorPath = "#app > div > form > div:nth-child(2) > div > div > input";
        var passwordFieldSelectorPath = "#app > div > form > div:nth-child(3) > div > div > input";
        var loginBtnSelectorPath = "#app > div > form > div:nth-child(5) > div > button";

        // 获取对象
        let usernameInputField = document.querySelector(usernameFieldSelectorPath);
        let passwordInputField = document.querySelector(passwordFieldSelectorPath);
        let loginButton = document.querySelector(loginBtnSelectorPath);

        // 若已经填写了参数, 则立刻点击一次登录
        if (usernameInputField.value != "" && passwordInputField.value != ""){
            loginButton.click();
        }

        // 关于 JavaScript 没有 sleep 函数的这个问题. 结合我的需求, 使用 递归加定时器 即可
        let JvtAutoLogin = function(i, j){
            console.log(i, j);
            // 已经不在登录页面
            if (document.title != "IP CAMERA" || document.baseURI.indexOf("login") == -1){
                return;
            }
            // 超出用户名或密码的范围
            if (i >= usernames.length){
                return;
            }

            // 更新用户名和密码, 并进行点击
            usernameInputField.value = usernames[i];
            passwordInputField.value = passwords[j];
            // 触发事件以使其生效
            // https://bbs.tampermonkey.net.cn/thread-1250-1-1.html
            usernameInputField.dispatchEvent(new Event('input'));
            passwordInputField.dispatchEvent(new Event('input'));
            console.log(usernameInputField.value);
            console.log(passwordInputField.value);
            loginButton.click();

            // 改变下一次递归的值
            if (j == passwords.length - 1){
                setTimeout(function(){JvtAutoLogin(i+1, j)}, 1000)
            } else {
                setTimeout(function(){JvtAutoLogin(i, j+1)}, 1000)
            }
        }
        setTimeout(function(){JvtAutoLogin(0, 0)}, 1000)
    }
})();