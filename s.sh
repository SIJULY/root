sudo bash -c '
# 备份原始的 sshd_config 文件
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak_$(date +"%Y%m%d%H%M%S")

echo ">>> 正在修改 SSH 配置文件..."

# 1. 允许 root 登录 (处理已存在、被注释等情况)
if grep -q "^#\?PermitRootLogin" /etc/ssh/sshd_config; then
    sed -i "s/^#\?PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
else
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
fi

# 2. 启用密码认证 (处理已存在、被注释等情况)
if grep -q "^#\?PasswordAuthentication" /etc/ssh/sshd_config; then
    sed -i "s/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
else
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
fi

echo ">>> SSH 配置修改完成。"
echo ""
echo ">>> 接下来，请为 root 用户设置密码。"
echo ">>> (输入密码时屏幕上不会显示，输入完成后按回车即可)"

# 3. 设置 root 用户密码
passwd root

# 4. 重启 SSH 服务以应用新配置
echo ""
echo ">>> 正在重启 SSH 服务..."
systemctl restart sshd

echo ""
echo "✅ 操作完成！"
echo "你现在可以断开当前连接，然后使用 root 用户和刚才设置的密码重新登录了。"
'
