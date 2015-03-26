
# PanGu.vim

盘古插件用于自动格式化、标准化中文排版。

它会将一些非标准，或不推荐的排版方式，在保存文件时进行自动格式化、标准化。

## 功能

* 中英文字符间增加一个半角空白。
* 中文前后的半角标点转成全角标点。
* 全角英文、数字转成半角字符。
* 剔除重复的中文标点符号。

## 支持的文件格式

默认支持以下文件格式：

* Markdown (*.md, *.markdown)
* Text (*.text, *.txt)
* Wiki (*.wiki)
* Vim 中文文档 (*.cnx)

如果你想在其他格式的文件中使用这个功能，可以在 vimrc 中开启。

** 注意：目前只对纯文本格式的文件支持较好，其他如 html 等，请谨慎开启。**

如果有合适的文件格式推荐，请提交 [Issue](https://github.com/hotoo/pangu.vim/issues)

开启方式：

```viml
autocmd BufWritePre *.ext,*.ext2 call PanGuSpace()
```

## 安装

via Vundle:

```
Bundle "hotoo/pangu.vim"
```

## 参考

* [中文文案排版指北](https://github.com/sparanoid/chinese-copywriting-guidelines)
