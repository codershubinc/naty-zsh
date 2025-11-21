# naty-zsh — Zsh theme

naty-zsh is a compact zsh theme that displays a short, random action phrase next to your prompt and a Git branch status indicator.

Files included

- `naty-zsh.zsh-theme` — the theme file (works with Oh My Zsh or plain zsh).
- `naty-zsh-random-texts.txt` — a list of short phrases used by the theme.

Install (Oh My Zsh)

1. Copy the theme and text file into your custom themes folder:

```sh
cp naty-zsh.zsh-theme ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/
cp naty-zsh-random-texts.txt ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/
```

2. Set the theme in `~/.zshrc`:

```sh
ZSH_THEME="naty-zsh"
```

3. Reload Zsh:

```sh
source ~/.zshrc
```

Manual usage

Source the theme directly in `~/.zshrc`:

```sh
source /path/to/naty-zsh.zsh-theme
```

Ensure `naty-zsh-random-texts.txt` sits next to the theme file so the random phrases are loaded.

Customization

- Edit `naty-zsh-random-texts.txt` to change the phrases that appear in the prompt.
- The theme exposes variables you can tweak inside `naty-zsh.zsh-theme`:
  - `ZSH_THEME_GIT_PROMPT_PREFIX`, `ZSH_THEME_GIT_PROMPT_SUFFIX`
  - `ZSH_THEME_GIT_PROMPT_DIRTY`, `ZSH_THEME_GIT_PROMPT_CLEAN`
  - `ZSH_THEME_DIR_PREFIX`, `ZSH_THEME_DIR_SUFFIX`, `ZSH_THEME_DIR_MAX_LENGTH`
- You can also edit the `PROMPT` value in `naty-zsh.zsh-theme` to change layout or remove text.

Content warning

The shipped `nauty-zsh-random-texts.txt` contains profanity and violent or aggressive phrasing. Edit the file if that is not suitable for your environment.

Example

When you're inside a Git repo you may see a line similar to:

`username Hacking [~/project] (main) Branch ✔`

Contributing

Contributions welcome. Please keep language and content appropriate when adding phrases.

License

This repository does not include a license file. Add a `LICENSE` if you want to set explicit usage terms.
