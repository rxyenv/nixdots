#!/usr/bin/env python3
import argparse
import re
import sys
import tomllib
from pathlib import Path


TEMPLATE_TARGETS = [
    ("templates/btop/theme.theme.tpl",         "~/.config/btop/themes/zen0x-current.theme"),
    ("templates/kitty/colors.conf.tpl",        "~/.config/kitty/colors.conf"),
    ("templates/zsh/fzf-theme.zsh.tpl",        "~/.config/zen0x/fzf-theme.zsh"),
    ("templates/hyprland/colors.conf.tpl",     "~/.config/hypr/colors.conf"),
    ("templates/hyprland/colors.lua.tpl",      "~/.config/hypr/colors.lua"),
    ("templates/hyprland/hyprlock.conf.tpl",   "~/.config/hypr/hyprlock.conf"),
    ("templates/waybar/colors.css.tpl",        "~/.config/waybar/colors.css"),
    ("templates/rofi/colors.rasi.tpl",         "~/.config/rofi/colors.rasi"),
    ("templates/swayosd/style.css.tpl",        "~/.config/swayosd/style.css"),
    ("templates/swayosd/config.toml.tpl",      "~/.config/swayosd/config.toml"),
    ("templates/swaync/colors.css.tpl",        "~/.config/swaync/colors.css"),
    ("templates/walker/colors.css.tpl",        "~/.config/walker/colors.css"),
    ("templates/gtk/settings.ini.tpl",         "~/.config/gtk-3.0/settings.ini"),
    ("templates/gtk/settings.ini.tpl",         "~/.config/gtk-4.0/settings.ini"),
    ("templates/gtk/gtk.css.tpl",              "~/.config/gtk-4.0/gtk.css"),
]


def repo_root() -> Path:
    return Path(__file__).resolve().parent


def get_value(data: dict, expression: str) -> str:
    parts = [part.strip() for part in expression.split("|")]
    path = parts[0].split(".")
    value = data

    for key in path:
        if not isinstance(value, dict) or key not in value:
            raise KeyError(expression)
        value = value[key]

    value = str(value)
    for filter_name in parts[1:]:
        if filter_name == "strip_hash":
            value = value.removeprefix("#")
        else:
            raise ValueError(f"Unknown template filter: {filter_name}")

    return value


def render(template: str, data: dict) -> str:
    pattern = re.compile(r"{{\s*([^}]+?)\s*}}")

    def replace(match: re.Match) -> str:
        return get_value(data, match.group(1))

    return pattern.sub(replace, template)


def load_theme(root: Path, theme: str) -> dict:
    theme_path = root / "palettes" / f"{theme}.toml"
    if not theme_path.exists():
        available = ", ".join(sorted(p.stem for p in (root / "palettes").glob("*.toml")))
        raise SystemExit(f"Theme '{theme}' not found. Available themes: {available}")

    with theme_path.open("rb") as file:
        return tomllib.load(file)


def resolve_target_path(root: Path, target_name: str, data: dict) -> Path:
    target_name = re.sub(r"\{([^}]+)\}", lambda m: get_value(data, m.group(1)), target_name)

    if target_name.startswith("~/"):
        return Path(target_name).expanduser()

    target_path = Path(target_name)
    if target_path.is_absolute():
        return target_path

    return root / target_name


def main() -> int:
    parser = argparse.ArgumentParser(description="Render zen0x theme templates.")
    parser.add_argument("theme", help="Theme slug from themes/<slug>/colors.toml")
    parser.add_argument("--dry-run", action="store_true", help="Validate and print target files without writing.")
    args = parser.parse_args()

    root = repo_root()
    data = load_theme(root, args.theme)
    data["env"] = {"home": str(Path.home())}
    is_light = data["meta"].get("variant") == "light"
    data["derived"] = {
        "prefer_dark": "0" if is_light else "1",
        "color_scheme": "prefer-light" if is_light else "prefer-dark",
    }
    rendered = []

    for template_name, target_name in TEMPLATE_TARGETS:
        template_path = root / template_name
        target_path = resolve_target_path(root, target_name, data)
        content = render(template_path.read_text(), data)
        rendered.append((template_path, target_path, content))

    for _, target_path, content in rendered:
        if args.dry_run:
            print(target_path)
            continue
        target_path.parent.mkdir(parents=True, exist_ok=True)
        if target_path.is_symlink():
            target_path.unlink()
        target_path.write_text(content)

    print(f"Generated theme: {data['meta']['name']} ({data['meta']['slug']})")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (KeyError, ValueError) as error:
        print(f"Template error: {error}", file=sys.stderr)
        raise SystemExit(1)
