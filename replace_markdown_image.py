from PIL import Image
import requests
import re
import sys

import warnings
from urllib3.exceptions import NotOpenSSLWarning

warnings.filterwarnings('ignore', category=NotOpenSSLWarning)

"""
这个脚本结合MWEB应用，将发布的 markdown 文件中所有的图片内容替换成自己博客站点里"可点击"，"可懒加载"的内容
"""

markdown_file_path = sys.argv[1]

def rectangeImage(image_url):
    '''
    返回给出的网络图片的长宽
    '''
    print(image_url)
    response = requests.get(image_url, stream=True)
    image = Image.open(response.raw)
    width, height = image.size
    return str(width) + 'x' + str(height)

# 读取Markdown文件
with open(markdown_file_path, 'r') as file:
    lines = file.readlines()

# 遍历每一行并替换图片语法
for i in range(len(lines)):
    line = lines[i]
    # 使用正则表达式匹配图片语法
    pattern = r'!\[(.*?)\]\((.*?)\)'
    match = re.search(pattern, line)
    
    # 如果匹配成功，则提取中括号和小括号中的内容，并替换为新的内容
    if match:
        alt_text = match.group(1)
        image_url = match.group(2)
        image_wh = rectangeImage(image_url)

        new_line = f'[![{alt_text}](//via.placeholder.com/{image_wh}?text="loading..."){{: data-src="{image_url}"}}]({image_url})\n'
        lines[i] = new_line

# 将修改后的内容写回Markdown文件
with open(markdown_file_path, 'w') as file:
    file.writelines(lines)
