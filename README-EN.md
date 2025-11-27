# 📧 OpenWRT Email Reception Function Experience Sharing

## 🌐 Language Versions

- **中文文档** 📖 [README.md](README.md)
- **English Documentation** 📖 [README-EN.md](README-EN.md)

---

> 🚀 Summarizing practical experience with OpenWRT email reception functionality, now sharing with everyone!

## 📋 Project Overview

OpenWRT 2102 includes the `fdm` component by default (in the feeds package directory), which can be used for sending emails but only supports the IMAP protocol.

### ⚠️ Issues Encountered

After testing, login issues were found:

**QQ Email verification failed**, error:
```bash
qq: unexpected data: 2 BAD Login parameters!
qq: fetching error. aborted
```

**Netease Email also reported errors**:
```bash
163: fetching
163: unexpected data: 3 NO SELECT Unsafe Login. Please contact kefu@188.com for help
163: fetching error. aborted
```

💡 **Conclusion**: Other email services can be queried and received normally, but there are many issues, and the project is basically no longer maintained. After comparison and evaluation, **fetchmail** was ultimately chosen.

---

## 📁 Project File Structure

```
fetchmail/
├── 📄 LICENSE
├── 🔧 Makefile
├── 📖 README.md
├── 📖 README-en.md
├── 📂 files/
│   ├── 🐚 fetchmail_deliver.sh
│   ├── ⚙️ fetchmailrc
│   └── 🔄 update_fetchmailrc.sh
└── 📂 patches/
    └── 🔧 001-imap-id-support-for-netease-163.patch
```

---

## 🔧 Core File Details

### 📂 files/fetchmail_deliver.sh

🎯 **Main Function**: Responsible for saving received email content as individual files in the `MAILDIR/new` directory, achieving atomic email processing.

**Enable Method**: Specify via the `mda` item in the configuration file
```bash
mda /usr/bin/fetchmail_deliver.sh
```

📁 **Directory Structure Explanation**:
- `MAILDIR` contains three directories
- `tmp`: Responsible for temporary cache files
- `new`: Final storage directory
- `extract`: Recommended for use as a separate reading operation directory during development (still atomic processing)

### ⚙️ files/fetchmailrc

📋 **fetchmail example configuration file**, supports IMAP protocol.

#### Configuration Item Details:

| Configuration Item | Description | Example |
|--------------------|-------------|---------|
| `poll imap.example.com` | 📡 Specify the mail server hostname to poll | `poll imap.qq.com` |
| `proto IMAP` | 🔌 Use IMAP protocol for communication | `proto IMAP` |
| `user user@example.com` | 👤 Email login username | `user your_email@qq.com` |
| `password example` | 🔑 Corresponding account IMAP service authorization code | `password your_password` |
| `ssl` | 🔒 Enable SSL/TLS encrypted connection | `ssl` |
| `sslcertck` | ✅ Enable SSL certificate verification | `sslcertck` |
| `sslcertfile /etc/ssl/certs/ca-certificates.crt` | 📜 Specify trusted CA certificate bundle path | `sslcertfile /etc/ssl/certs/ca-certificates.crt` |
| `keep` | 💾 Keep original emails on the server | `keep` |
| `# limit 100000` | 📏 Limit download email size (need to uncomment) | `# limit 100000` |
| `mda /usr/bin/fetchmail_deliver.sh` | 📨 Specify mail delivery agent | `mda /usr/bin/fetchmail_deliver.sh` |

### 🔄 files/update_fetchmailrc.sh

🛠️ **Configuration file modification script**, used for modifying the example configuration file. Refer to comments within the script for specific usage.

### 🔧 patches/001-imap-id-support-for-netease-163.patch

🐛 **Issue Fix**: Resolves Netease domain email login issues

#### 🔍 Root Cause
Netease email requires clients to indicate relevant "identity" information to allow connections, otherwise it returns the error:
```
Unsafe Login. Please contact kefu@188.com for help
```

📚 **Reference Documentation**:
[Netease Email Security Login Instructions](https://help.mail.163.com/faqDetail.do?code=d7a5dc8471cd0c0e8b4b8f4f8e49998b374173cfe9171305fa1ce630d7f67ac2eda07326646e6eb0)

#### 🛠️ Solution
When detecting Netease domain email, send ID extension command format compliant with RFC 2971 during login:
```bash
a001 ID ("name" "fetchmail" "version" "6.4.39" "vendor" "OpenWRT")
```

📖 **RFC 2971 Standard**:
[RFC 2971 Document](https://www.ietf.org/rfc/rfc2971.txt)

### 🔧 Makefile

📦 **fetchmail source code address**:
https://sourceforge.net/projects/fetchmail/

⚠️ **Important Notes**:
- This version of fetchmail source code is no longer maintained
- Due to OpenWRT 2102 version openssl version limitations, it's not suitable for the latest fetchmail
- Although not the latest version, basic email functionality is available

---

## 📨 Email Information Processing

### 📱 Using mblaze to Process Emails

OpenWRT has built-in specialized processing software `mblaze`, component path:
```
Mail  --->
    mblaze... Unix utilities to deal with Maildir
```

### 🔄 Processing Flow

After processing with `files/fetchmail_deliver.sh`, it's recommended to move emails to the `extract` directory for individual processing.

#### 📝 Common Command Line Operations

> ⚠️ **Note**: Command line tools perform traversal operations on all files in the entire directory

```bash
# 📧 Extract Sender (From)
maddr -a from /tmp/maildir/extract/ 2>/dev/null | head -n 1

# 📨 Extract Recipient (To)
maddr -a from /tmp/maildir/extract/ 2>/dev/null | sed -n '2p'

# 📋 Extract Subject
mhdr -h subject /tmp/maildir/extract/ 2>/dev/null
mhdr -h subject /tmp/maildir/extract/

# 📄 Extract Body (text/plain)
mshow -O /tmp/maildir/extract/ 2
```

---

## 🚀 Quick Start

1. **📥 Clone the project**
2. **⚙️ Configure email information** (modify `files/fetchmailrc`)
3. **🔧 Apply patches** (if Netease email support is needed)
4. **▶️ Run scripts** to start email reception

---

## 🤝 Contributing

Welcome to submit Issues and Pull Requests to improve this project!

---

<div align="center">

**🌟 If this project helps you, please give it a Star for support!**

</div>
