vim.keymap.set({ "n", "x" }, "j", function()
  return require("faster-jk").expr("j")
end, {
  expr = true,
  silent = true,
  desc = "faster-jk down",
})

vim.keymap.set({ "n", "x" }, "k", function()
  return require("faster-jk").expr("k")
end, {
  expr = true,
  silent = true,
  desc = "faster-jk up",
})
