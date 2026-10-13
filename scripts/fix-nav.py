#!/usr/bin/env python3
"""构建后处理：改写 EPUB 目录里的作品标题条目。

pandoc 无法为目录单独指定标题文本——目录条目直接取自正文标题的纯文本，
而第二至五章的作品标题是「篇名[作者]{.zuozhe}」（篇名在前、作者小一号）。
正文保持这种版式，但目录（TOC）里应显示「作者《篇名》」。

因此构建完成后改写两个目录文件：
  - EPUB/nav.xhtml（EPUB3 nav）：`篇名<span class="zuozhe">作者</span>`
  - EPUB/toc.ncx（EPUB2 兼容 NCX）：`篇名作者`
两者均改为 `作者《篇名》`。映射以 manuscript/ 里的 ### 标题为准。

重新打包时保持 mimetype 作为 zip 第一个条目且不压缩（EPUB 规范要求）。
"""
import re
import os
import sys
import glob
import zipfile

HEADING = re.compile(r"^### (.+)\[(.+)\]\{\.zuozhe\}\s*$")


def parse_pairs():
    pairs = []
    for f in sorted(glob.glob("manuscript/*.md")):
        for line in open(f, encoding="utf-8"):
            m = HEADING.match(line.rstrip("\n"))
            if m:
                pairs.append((m.group(1), m.group(2)))
    return pairs


def fix_nav(text, pairs):
    for title, author in pairs:
        old = ">%s<span class=\"zuozhe\">%s</span></a>" % (title, author)
        new = ">%s《%s》</a>" % (author, title)
        text = text.replace(old, new)
    return text


def fix_ncx(text, pairs):
    for title, author in pairs:
        old = ">%s%s</text>" % (title, author)
        new = ">%s《%s》</text>" % (author, title)
        text = text.replace(old, new)
    return text


def main():
    epub_path = sys.argv[1]
    pairs = parse_pairs()
    tmp = epub_path + ".tmp"
    with zipfile.ZipFile(epub_path, "r") as zin:
        with zipfile.ZipFile(tmp, "w") as zout:
            for item in zin.infolist():
                data = zin.read(item.filename)
                if item.filename == "EPUB/nav.xhtml":
                    data = fix_nav(data.decode("utf-8"), pairs).encode("utf-8")
                elif item.filename == "EPUB/toc.ncx":
                    data = fix_ncx(data.decode("utf-8"), pairs).encode("utf-8")
                compress = zipfile.ZIP_STORED if item.filename == "mimetype" else zipfile.ZIP_DEFLATED
                zout.writestr(item, data, compress_type=compress)
    os.replace(tmp, epub_path)
    print("已改写目录：%d 个作品标题条目 → 作者《篇名》" % len(pairs))


if __name__ == "__main__":
    main()
