# 📧 OpenWRT 邮件接收功能经验分享


## 🌐 语言版本

- **中文文档** 📖 [README.md](README.md)
- **English Documentation** 📖 [README-EN.md](README-EN.md)

---



> 🚀 总结OpenWRT邮件接收功能的实践经验，现在分享给大家！

## 📋 项目概述

OpenWRT 2102 默认包含有组件 `fdm`（在 feeds 包目录中），可用于发送邮件，但只支持 IMAP 协议。

### ⚠️ 遇到的问题

经过亲测发现登录存在问题：

**QQ邮箱验证不通过**，报错：
```bash
qq: unexpected data: 2 BAD Login parameters!
qq: fetching error. aborted
```

**网易邮箱也报错**：
```bash
163: fetching
163: unexpected data: 3 NO SELECT Unsafe Login. Please contact kefu@188.com for help
163: fetching error. aborted
```

💡 **结论**：其他邮箱可以正常查询接收，但存在诸多问题，且项目基本停止维护。经过对比权衡，最终选择了 **fetchmail**。

---

## 📁 项目文件结构

```
fetchmail/
├── 📄 LICENSE
├── 🔧 Makefile
├── 📖 README.md
├── 📂 files/
│   ├── 🐚 fetchmail_deliver.sh
│   ├── ⚙️ fetchmailrc
│   └── 🔄 update_fetchmailrc.sh
└── 📂 patches/
    └── 🔧 001-imap-id-support-for-netease-163.patch
```

---

## 🔧 核心文件详解

### 📂 files/fetchmail_deliver.sh

🎯 **主要功能**：负责将接收到的邮件内容以单独一封的形式保存在 `MAILDIR/new` 目录中，实现对邮件的原子化处理。

**启用方式**：通过配置文件的 `mda` 项指定
```bash
mda /usr/bin/fetchmail_deliver.sh
```

📁 **目录结构说明**：
- `MAILDIR` 包含三个目录
- `tmp`：负责临时缓存文件
- `new`：最终保存目录
- `extract`：开发中建议用作单独读取的操作目录（仍为原子化处理）

### ⚙️ files/fetchmailrc

📋 **fetchmail 示例配置文件**，支持 IMAP 协议。

#### 配置项详解：

| 配置项 | 说明 | 示例 |
|--------|------|------|
| `poll imap.example.com` | 📡 指定要轮询的邮件服务器主机名 | `poll imap.qq.com` |
| `proto IMAP` | 🔌 使用 IMAP 协议通信 | `proto IMAP` |
| `user user@example.com` | 👤 登录邮箱的用户名 | `user your_email@qq.com` |
| `password example` | 🔑 对应账户的 IMAP 服务授权码 | `password your_password` |
| `ssl` | 🔒 启用 SSL/TLS 加密连接 | `ssl` |
| `sslcertck` | ✅ 启用 SSL 证书验证 | `sslcertck` |
| `sslcertfile /etc/ssl/certs/ca-certificates.crt` | 📜 指定受信任的 CA 证书包路径 | `sslcertfile /etc/ssl/certs/ca-certificates.crt` |
| `keep` | 💾 保留服务器上的原始邮件 | `keep` |
| `# limit 100000` | 📏 限制下载邮件大小（需取消注释） | `# limit 100000` |
| `mda /usr/bin/fetchmail_deliver.sh` | 📨 指定邮件投递代理 | `mda /usr/bin/fetchmail_deliver.sh` |

### 🔄 files/update_fetchmailrc.sh

🛠️ **配置文件修改脚本**，用于对示例配置文件进行修改处理，具体用法请参考脚本内的注释。

### 🔧 patches/001-imap-id-support-for-netease-163.patch

🐛 **问题修复**：解决网易域邮箱的登录问题

#### 🔍 问题根因
网易邮箱需要客户端表明相关"身份"信息才能允许连接，否则会返回错误：
```
Unsafe Login. Please contact kefu@188.com for help
```

📚 **参考文档**：
[网易邮箱安全登录说明](https://help.mail.163.com/faqDetail.do?code=d7a5dc8471cd0c0e8b4b8f4f8e49998b374173cfe9171305fa1ce630d7f67ac2eda07326646e6eb0)

#### 🛠️ 解决方案
在检测到网易域邮箱时，在登录时发送符合 RFC 2971 的 ID 扩展命令格式：
```bash
a001 ID ("name" "fetchmail" "version" "6.4.39" "vendor" "OpenWRT")
```

📖 **RFC 2971 标准**：
[RFC 2971 文档](https://www.ietf.org/rfc/rfc2971.txt)

### 🔧 Makefile

📦 **fetchmail 源码地址**：
https://sourceforge.net/projects/fetchmail/

⚠️ **重要提示**：
- 该版本的 fetchmail 源码已停止维护
- 由于 OpenWRT 2102 版本的 openssl 版本限制，不适合最新的 fetchmail
- 虽不是最新版本，但基本邮件功能可用

---

## 📨 邮件信息处理

### 📱 使用 mblaze 处理邮件

OpenWRT 内置专门的处理软件 `mblaze`，组件路径：
```
Mail  --->
    mblaze... Unix utilities to deal with Maildir
```

### 🔄 处理流程

通过 `files/fetchmail_deliver.sh` 处理后，建议将邮件移动到 `extract` 目录进行逐封处理。

#### 📝 常用命令行操作

> ⚠️ **注意**：命令行工具会对整个目录的所有文件进行遍历操作

```bash
# 📧 提取发件人 (From)
maddr -a from /tmp/maildir/extract/ 2>/dev/null | head -n 1

# 📨 提取收件人 (To)
maddr -a from /tmp/maildir/extract/ 2>/dev/null | sed -n '2p'

# 📋 提取主题 (Subject)
mhdr -h subject /tmp/maildir/extract/ 2>/dev/null
mhdr -h subject /tmp/maildir/extract/

# 📄 提取正文 (Body - text/plain)
mshow -O /tmp/maildir/extract/ 2
```

---

## 🚀 快速开始

1. **📥 克隆项目**
2. **⚙️ 配置邮箱信息**（修改 `files/fetchmailrc`）
3. **🔧 应用补丁**（如需网易邮箱支持）
4. **▶️ 运行脚本**开始邮件接收

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目！

---

<div align="center">

**🌟 如果这个项目对你有帮助，请给个 Star 支持一下！**

</div>
