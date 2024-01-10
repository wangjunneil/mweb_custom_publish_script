#!/bin/zsh

# 赋值MWEB应用自身变量
FILENAME={{fileName}}
FILEPATH="{{fileDir}}"
CURRENT_DATE=$(date +%Y-%m-%d)

# 获取文章UUID，即本地存储的文件名称
UUID="${FILENAME%.*}"

# 本地博客目录
BLOGGER_DIR="/Users/wangjun/workspace/wangjun/blog-source"

# 文章发布目录
PUBLISH_DIR="$BLOGGER_DIR/_posts"

# 替换图片的脚本路径
RE_IMAGE_SCRIPT="$BLOGGER_DIR/replace_markdown_image.py"

# 调用ChatGPT获取文章slug
JSON_DATA="{\"content\":\"将中括号中的文章标题[{{title}}]翻译成英文的slug方式返回，英文单词不超过6个单词\"}"
SLUG=$(curl -X POST -H "Content-Type: application/json" -d "$JSON_DATA" --progress-bar https://xxx.xxx.com/jaskan/gpt)
SLUG=$(echo $SLUG | tr -d '"')
echo "NAME: \033[47;30m {{title}} \033[0m"
echo "SLUG: \033[47;30m $SLUG \033[0m"

# 获取MWEB编辑器的SQLITE数据库地址
SQLITE_PATH="${FILEPATH%/*}/mainlib.db"

# 查询出文章定义的标签TAGS
TAGS=$(sqlite3 "$SQLITE_PATH" "select group_concat(name,',') from tag where uuid in (select rid from tag_article where aid = $UUID);")
# 查询出文章定义的分类CAT
CATS=$(sqlite3 "$SQLITE_PATH" "select group_concat(name,',') from cat where uuid in (select rid from cat_article where aid = $UUID);")

echo "TAGS: \033[47;30m $TAGS \033[0m"
echo "CATS: \033[47;30m $CATS \033[0m"

# 拷贝到文章目录
cp "{{filePath}}" "${PUBLISH_DIR}/$CURRENT_DATE-${SLUG}.md"

# 替换 jekyll 模板头
sed -i '' "1s/.*/---\\
title: {{title}}\\
name: $SLUG\\
date: $CURRENT_DATE\\
tags: [$TAGS]\\
excerpt: {{title}}\\
categories: [$CATS]\\
---\\
\\
* 目录\\
{:toc}\\
\\
/" "${PUBLISH_DIR}/$CURRENT_DATE-${SLUG}.md"

# 图片替换
python3 $RE_IMAGE_SCRIPT "${PUBLISH_DIR}/$CURRENT_DATE-${SLUG}.md"

# 启动 jekyll 打开浏览器预览文章
jekyll s -s $BLOGGER_DIR -d "$BLOGGER_DIR/_site"