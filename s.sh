#!/bin/bash

# --- 脚本：s.sh (增强版) ---
# 功能：
# 1. 允许 root 密码登录
# 2. 循环提示输入密码，直到两次输入一致
# 3. 输入密码时会显示字符
# 4. 成功后提醒用户修改密码

echo ">>> 正在备份并修改 SSH 配置文件..."

# 备份原始的 sshd_config 文件，这是一个好习惯
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak_$(date +"%Y%m%d%H%M%S")

# 智能地修改或添加 PermitRootLogin yes
if grep -q "^#\?PermitRootLogin" /etc/ssh/sshd_config; then
    sudo sed -i "s/^#\?PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
else
    echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config > /dev/null
fi

# 智能地修改或添加 PasswordAuthentication yes
if grep -q "^#\?PasswordAuthentication" /etc/ssh/sshd_config; then
    sudo sed -i "s/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
else
    echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config > /dev/null
fi

echo ">>> SSH 配置修改完成。"
echo ""

# --- 核心修改部分：密码输入循环 ---
while true; do
    # 使用 read -p 来显示提示符，并且输入会显示出来
    read -p "请输入新的 root 密码 (密码会显示): " ROOT_PASSWORD
    echo
    read -p "请再次确认密码: " ROOT_PASSWORD_CONFIRM
    echo

    if [ "$ROOT_PASSWORD" = "$ROOT_PASSWORD_CONFIRM" ]; then
        if [ -z "$ROOT_PASSWORD" ]; then
            echo "错误：密码不能为空，请重新输入。"
            echo ""
        else
            # 两次密码一致且不为空，跳出循环
            break
        fi
    else
        echo "错误：两次输入的密码不匹配，请重新输入。"
        echo ""
    fi
done

echo ">>> 正在设置 root 密码..."
# 使用 chpasswd 非交互式地设置密码，更可靠
echo "root:$ROOT_PASSWORD" | sudo chpasswd

if [ $? -eq 0 ]; then
    echo ">>> root 密码更新成功。"
else
    echo ">>> 错误：设置 root 密码失败！"
    exit 1
fi

echo ""
echo ">>> 正在重启 SSH 服务..."
sudo systemctl restart sshd

echo ""
echo "✅ 操作完成！"
echo "你现在可以断开当前连接，然后使用 root 用户和刚才设置的密码重新登录了。"
echo ""
echo "⚠️  安全建议：为了您的服务器安全，强烈建议您在首次使用新密码登录后，立即使用 \`passwd\` 命令修改为您自己的强密码！"
