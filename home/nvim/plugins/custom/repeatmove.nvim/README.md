# repeatmove.nvim

Repeat paired normal-mode motions with alternate keys in Neovim.

## What it does

With this config:

```lua
require('repeatmove').setup({
  move = {
    { '[f', ']f' },
    { '[c', ']c' },
    { '[d', ']d' },
  },
  repeat_keys = {
    { '[', ']' },
    { ',', ';' },
  },
})
```

After any tracked move runs:

- `[` and `;` repeat the backward move
- `]` and `,` repeat the forward move
- any other non-count key clears the active repeat state
- outside active repeat state, repeat keys keep their original behavior

Examples:

- after `]f`, pressing `;` runs `[f`
- after `]d`, pressing `]` runs `]d`
- after `[c`, pressing `,` runs `]c`

## Requirements

- Neovim >= 0.10

## Installation

### lazy.nvim

```lua
{
  'dokee39/repeatmove.nvim',
  config = function()
    require('repeatmove').setup({
      move = {
        { '[f', ']f' },
        { '[c', ']c' },
        { '[d', ']d' },
      },
      repeat_keys = {
        { '[', ']' },
        { ',', ';' },
      },
    })
  end,
}
```

### packer.nvim

```lua
use({
  'dokee39/repeatmove.nvim',
  config = function()
    require('repeatmove').setup({
      move = {
        { '[f', ']f' },
        { '[c', ']c' },
        { '[d', ']d' },
      },
      repeat_keys = {
        { '[', ']' },
        { ',', ';' },
      },
    })
  end,
})
```

## Configuration

### Single move pair

```lua
require('repeatmove').setup({
  move = { '[f', ']f' },
  repeat_keys = { ',', ';' },
})
```

### Multiple move pairs

```lua
require('repeatmove').setup({
  move = {
    { '[f', ']f' },
    { '[c', ']c' },
    { '[d', ']d' },
  },
  repeat_keys = { ',', ';' },
})
```

### Multiple repeat key pairs

```lua
require('repeatmove').setup({
  move = {
    { '[f', ']f' },
    { '[c', ']c' },
  },
  repeat_keys = {
    { '[', ']' },
    { ',', ';' },
  },
})
```

### Multiple groups

```lua
require('repeatmove').setup({
  groups = {
    {
      move = {
        { '[f', ']f' },
        { '[c', ']c' },
      },
      repeat_keys = {
        { ',', ';' },
      },
    },
    {
      move = {
        { '[d', ']d' },
      },
      repeat_keys = {
        { '[', ']' },
      },
    },
  },
})
```

The legacy alias `repeat = ...` is also accepted.

## API

### `require('repeatmove').setup(opts)`

Accepted shapes:

```lua
{
  move = { '[f', ']f' },
  repeat_keys = { ',', ';' },
}
```

```lua
{
  move = {
    { '[f', ']f' },
    { '[c', ']c' },
  },
  repeat_keys = {
    { '[', ']' },
    { ',', ';' },
  },
}
```

```lua
{
  groups = {
    {
      move = { { '[f', ']f' }, { '[c', ']c' } },
      repeat_keys = { { ',', ';' } },
    },
    {
      move = { { '[d', ']d' } },
      repeat_keys = { { '[', ']' } },
    },
  },
}
```

### `require('repeatmove').clear()`

Clears the active repeat state manually.

## Behavior notes

- Only normal mode is supported.
- Repeat keys are intercepted only after a tracked move has just run.
- Any non-repeat, non-count key clears the active repeat state.
- Counts are forwarded, for example `3;`.
- Outside active repeat state, repeat keys fall through to their original mappings or built-in behavior.
- If `[` or `]` are used as repeat keys, they cannot start a fresh bracket-prefixed command while repeat state is active.
- Repeat mappings are installed buffer-locally only while repeat state is active, with `nowait = true`, to avoid prefix wait issues.
- State is cleared lazily on the next key if you switch buffer or leave normal mode.

## How it works

The plugin watches typed keys with `vim.on_key()`, remembers the most recent tracked move pair, and installs temporary buffer-local repeat mappings for the active buffer only. Repeats are replayed through `feedkeys()`.

## License

MIT
