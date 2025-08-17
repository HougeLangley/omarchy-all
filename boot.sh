#!/bin/bash

# ANSI艺术标题
ansi_art='                 ▄▄▄                                                   
 ▄█████▄    ▄███████████▄    ▄███████   ▄███████   ▄███████   ▄█   █▄    ▄█   █▄ 
███   ███  ███   ███   ███  ███   ███  ███   ███  ███   ███  ███   ███  ███   ███
███   ███  ███   ███   ███  ███   ███  ███   ███  ███   █▀   ███   ███  ███   ███
███   ███  ███   ███   ███ ▄███▄▄▄███ ▄███▄▄▄██▀  ███       ▄███▄▄▄███▄ ███▄▄▄███
███   ███  ███   ███   ███ ▀███▀▀▀███ ▀███▀▀▀▀    ███      ▀▀███▀▀▀███  ▀▀▀▀▀▀███
███   ███  ███   ███   ███  ███   ███ ██████████  ███   █▄   ███   ███  ▄██   ███
███   ███  ███   ███   ███  ███   ███  ███   ███  ███   ███  ███   ███  ███   ███
 ▀█████▀    ▀█   ███   █▀   ███   █▀   ███   ███  ███████▀   ███   █▀    ▀█████▀ 
                                       ███   █▀                                  '

# 清屏并显示艺术标题
clear
echo -e "\n$ansi_art\n"

# 检测发行版并相应地安装git
install_git() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            arch)
                if ! command -v sudo &> /dev/null; then
                    pacman -Sy --noconfirm --needed sudo
                fi
                sudo pacman -Sy --noconfirm --needed git
                ;;
            debian|ubuntu)
                # 检查sudo是否存在，如果不存在则安装
                if ! command -v sudo &> /dev/null; then
                    apt update && apt install -y sudo
                fi
                sudo apt update && sudo apt install -y git
                ;;
            *)
                echo "不支持的发行版: $ID"
                echo "请手动安装git并重新运行脚本"
                exit 1
                ;;
        esac
    else
        echo "无法检测发行版"
        echo "请手动安装git并重新运行脚本"
        exit 1
    fi
}

# 检查并安装git
if ! command -v git &> /dev/null; then
    echo "正在安装git..."
    install_git
fi

# 使用自定义仓库（如果指定），否则默认使用HougeLangley/omarchy-all
OMARCHY_REPO="${OMARCHY_REPO:-HougeLangley/omarchy-all}"

echo -e "\n正在克隆Omarchy从: https://github.com/${OMARCHY_REPO}.git"
rm -rf ~/.local/share/omarchy/
git clone "https://github.com/${OMARCHY_REPO}.git" ~/.local/share/omarchy >/dev/null

# 如果指定了自定义分支，则使用该分支
if [[ -n "$OMARCHY_REF" ]]; then
    echo -e "\e[32m使用分支: $OMARCHY_REF\e[0m"
    cd ~/.local/share/omarchy
    git fetch origin "${OMARCHY_REF}" && git checkout "${OMARCHY_REF}"
    cd -
fi

echo -e "\n开始安装..."
source ~/.local/share/omarchy/install.sh
