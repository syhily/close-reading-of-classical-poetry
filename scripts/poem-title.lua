-- 诗块标题出块：把 ::: {.poem} 内首段加粗诗作题（如「**敕勒歌**」、
-- 「**短歌行**　曹操」）挪到诗块之外，包为 .shiti Div（居中）；
-- 加粗部分再包 .heiti 行内 span（黑体）。两个类均为 assets/epub.css
-- 既有规则，不新增任何 CSS。诗块本身只留诗行，交给 poem-stanzas.lua
-- 处理（本过滤器须在 poem-stanzas.lua 之前运行）。
function Div(el)
  if not el.classes:includes("poem") then
    return nil
  end
  local first = el.content[1]
  if not (first and first.t == "Para" and first.content[1] and first.content[1].t == "Strong") then
    return nil
  end
  local inlines = {}
  for _, il in ipairs(first.content) do
    if il.t == "Strong" then
      table.insert(inlines, pandoc.Span({ il }, pandoc.Attr("", { "heiti" })))
    else
      table.insert(inlines, il)
    end
  end
  local title = pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", { "shiti" }))
  table.remove(el.content, 1)
  return { title, el }
end
