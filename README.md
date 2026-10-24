# Fork 主的补充
本 Fork 已经由玩家 chpwang 在原作者 gaoryrt 建立的 theme 上做了大量的修改，出于对原作者的敬畏，保留了他以下言论

---

# hexo-theme-pln
A plain theme for hexo  
同时也是一个纯文字友好的Hexo主题。  
**喜欢的用，不喜欢就别用。**  
[demo](http://gaoryrt.com)  
![index](/screenShots/ver1.0-index.jpg)
![tags](/screenShots/ver1.0-tags.jpg)
![article](/screenShots/ver1.0-article.jpg)
![dropdown](/screenShots/ver1.0-dropdown.jpg)
*screenshots capcured at 2016-05-14, ver1.0*
***

---
## 轮到我上场了

当前主题基于原 PLN 风格长期维护，目前已经针对 **Hexo 8**、现代 Markdown renderer、Dart Sass 和响应式页面进行了较大幅度的现代化修改。

本仓库仍然保持为独立 Git repository，并通过 Git submodule 挂载到 blog：

``` text
blog/themes/pln
```

---

## 使用环境

PLN 当前由 blog 父项目提供构建工具。

推荐：

``` text
Node.js 24 LTS
Hexo 8.1.2
Dart Sass 1.105.2
```

不要使用旧版：

``` text
node-sass
```

---

## 目录结构

主要结构：

``` text
hexo-theme-pln/
├── layout/
│   └── _partial/
├── scss/
│   ├── main.scss
│   ├── navigator.scss
│   ├── search.scss
│   ├── posts.scss
│   ├── article.scss
│   ├── toc.scss
│   ├── pager.scss
│   ├── footer.scss
│   ├── highlight.scss
│   └── animation.scss
├── source/
│   ├── css/
│   │   └── m.min.css
│   ├── js/
│   │   ├── theme-mode.js
│   │   └── toc.js
│   ├── bootstrap/
│   ├── font-awesome/
│   └── ...
└── _config.yml
```

`scss/` 是主题样式源码。

最终提供给浏览器的是：

``` text
source/css/m.min.css
```

---

## SCSS 构建

从 blog 根目录运行：

``` bash
cd ~/blog
npm run css
```

实际流程：

``` text
themes/pln/scss/main.scss
↓
Dart Sass
↓
themes/pln/source/css/m.min.css
```

当前 CSS 编译使用 compressed output，并且不生成 source map。

修改任何 SCSS 后都必须重新运行：

``` bash
npm run css
```

并把新的：

``` text
source/css/m.min.css
```

一起提交。

---

## SCSS 模块

`main.scss` 负责全局变量和主要布局，并加载：

``` scss
@use "navigator";
@use "search";
@use "posts";
@use "article";
@use "toc";
@use "pager";
@use "footer";
@use "highlight";
@use "animation";
```

不同模块尽量只负责自己的 presentation concern。

---

## Light Mode / Dark Mode

主题颜色使用 CSS Custom Properties。

Light / Dark 都使用同一套组件结构，只切换变量。

切换逻辑：

``` text
source/js/theme-mode.js
```

行为：

``` text
第一次访问
→ 跟随 prefers-color-scheme

手动切换
→ localStorage 记录 light / dark
```

主题脚本在 CSS 加载前尽早应用模式，避免明显的 Light Mode flash。

---

## 导航栏

桌面和移动端导航都保留原 PLN 的简洁 icon 风格。

移动端要求：

``` text
所有 5 个主要导航 icon 都保留
```

不要重新加入：

``` scss
li.archives {
    display: none;
}
```

之类的旧移动端隐藏规则。

---

## 文章阅读宽度

页面使用统一的 responsive gutter。

宽屏下：

``` text
首页
文章
archives
tags
```

都使用相同的主内容留白逻辑。

手机下自动减小到较窄 gutter，避免正文过窄。

---

## TOC

文章目录使用 Hexo 自带：

``` text
toc()
```

生成。

模板：

``` text
layout/_partial/article.ejs
```

目录范围：

``` text
H2
H3
H4
```

---

## TOC Edge Rail

目录默认隐藏。

页面左侧是一条非常低干扰的 full-height edge rail。

特点：

``` text
极窄
和页面背景融合
默认只有很淡的视觉提示
hover / focus 时才略微显色
```

目的不是突出“这里有一个按钮”，而是尽量降低阅读过程中的视觉干扰。

---

## TOC Desktop / Tablet

宽页面下打开 TOC：

``` text
目录占用页面原本左右的空白
正文宽度不变
正文整体移动
右侧仍保留舒适 gutter
```

目录关闭和打开使用同一条 edge rail。

Esc 也可以关闭。

---

## TOC Mobile

手机下：

``` text
目录覆盖正文
```

关闭方式：

``` text
X
点击 backdrop
Esc
点击目录项
```

---

## 返回顶部

返回顶部箭头固定在正文右侧 gutter 中。

它不会依赖 footer 本身的普通 flow 定位。

当桌面目录展开、正文移动时：

``` text
返回顶部箭头也同步移动
```

避免覆盖正文。

手机下箭头缩小，保证整个 control 都位于正文右侧留白中。

---

## Markdown 表格

文章中的 Markdown table 在模板中包装为：

``` html
<div class="table-wrapper">
  <table>
    ...
  </table>
</div>
```

重要原则：

``` text
<table> 始终保持原生 table layout
wrapper 负责 overflow
```

不要把：

``` css
table {
    display: block;
}
```

重新加回来。

这会破坏 table formatting context，导致表格本身和外层宽度不一致。

普通表格：

``` text
100% 宽
允许单元格自然换行
```

较宽表格：

``` text
wrapper 内横向滚动
```

---

## 代码高亮

Hexo 8 在服务器生成阶段完成 Highlight.js markup。

PLN：

``` text
scss/highlight.scss
```

只负责：

``` text
布局
字体
padding
inline code
pre
```

具体语法颜色继续由：

``` text
source/css/highlight/styles/vs2015.css
```

提供。

不要重新加入浏览器端：

``` text
highlight.pack.js
hljs.initHighlightingOnLoad()
```

---

## MathJax

数学内容由 `hexo-math` 在 blog 层生成 MathJax SVG。

PLN 的：

``` text
article.scss
```

负责 MathJax 的：

``` text
block centering
overflow
列表中的颜色继承
```

不要把数学引擎逻辑放回主题 JavaScript。

---

## 中文 Markdown

中文粗体兼容属于 blog renderer 层：

``` text
marked-cjk-friendly
```

不属于 PLN。

PLN 只负责生成后的 HTML presentation。

---

## Bootstrap / Font Awesome

为了兼容原主题和旧页面结构，PLN 仍然保留本地：

``` text
Bootstrap 3
Font Awesome 4.5
```

不要为了“现代化”而单独升级它们。

这类升级会引入大量 DOM / selector / icon compatibility 改动，目前没有必要。

---

## 开发流程

进入 blog：

``` bash
cd ~/blog
nvm use
```

修改 PLN 后：

``` bash
npm run css
npm run build
npx hexo s
```

检查：

``` text
首页
文章页
archives
tags
Light / Dark
TOC
代码
MathJax
表格
移动端
```

---

## Git

PLN 是独立仓库。

主题修改完成后：

``` bash
cd ~/blog/themes/pln

git status
git add -A
git commit -m "Update PLN theme"
git push origin HEAD
```

然后回父仓库记录新的 submodule SHA：

``` bash
cd ~/blog

git add themes/pln
git commit -m "Update PLN theme revision"
git push origin master
```

必须保证：

``` text
PLN commit 已经 push
↓
blog 才 push submodule pointer
```

---

## 设计原则

PLN 当前继续保持原来的核心方向：

``` text
文本优先
低视觉干扰
少量颜色
较大留白
简单导航
```

新增功能也遵守同样原则。

例如 TOC 并没有设计成一直悬浮的大面板，而是隐藏到页面边缘。

Dark Mode 也没有大量加入卡片、阴影或装饰。

目标是：

``` text
功能存在
但不要让功能本身抢走正文的注意力
```

---

## 不要做的事情

不要重新引入：

``` text
node-sass
Stylus 作为主样式链
浏览器端 Highlight.js
display:block 的 table
```

不要在没有完整视觉回归测试的情况下：

``` text
升级 Bootstrap
升级 Font Awesome major version
批量重写旧 EJS
```

PLN 当前已经可以稳定运行在现代 Hexo 环境下。

后续修改以：

``` text
小范围
可验证
保持视觉语言
```

为原则。


# license
<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/80x15.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
