-- 选文块诗作题：::: {.xuanwen} 内首个段落若以加粗开头（诗作题，
-- 如「**陌上桑**」或「**春江花月夜**　张若虚」），包一层 .shiti Div，
-- CSS 使其居中——与 ::: {.poem} 短诗块内诗作题的居中黑体版式一致。
-- 不能用 CSS :first-child / :has 实现：Boox（NeoReader）等阅读器
-- 对 :has 支持不全，且无法判断「整段加粗」，故在 AST 层显式标记。
function Div(el)
  if not el.classes:includes("xuanwen") then
    return nil
  end
  local first = el.content[1]
  if first
    and first.t == "Para"
    and first.content[1]
    and first.content[1].t == "Strong"
  then
    el.content[1] = pandoc.Div({ first }, pandoc.Attr("", { "shiti" }))
    return el
  end
end
