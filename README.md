
总结OpenWRT 邮件接收功能的经验，现在分享出来。


OpenWRT 2102默认包含有组件fdm，在feeds包目录。可用于发送邮件，只支持IMAP协议。

亲测发现登录存在问题，QQ邮箱验证不通过，报错
```
qq: unexpected data: 2 BAD Login parameters!
qq: fetching error. aborted
```
网易邮箱也报错
```
163: fetching
163: unexpected data: 3 NO SELECT Unsafe Login. Please contact kefu@188.com for help
163: fetching error. aborted
```

其他邮箱是可以正常查询接收。但存在诸多问题，且项目基本停止维护，最终对比权衡选择了fetchmail。



# 各个文件的作用


## files/fetchmail_deliver.sh

主要负责把接收到邮件内容，进行单独一封的形式保存在`MAILDIR/new`当中，实现对邮件原子化的处理。

是否生效，通过配置文件mda项指定
```
mda /usr/bin/fetchmail_deliver.sh
```

`MAILDIR`有三个目录，tmp是负责临时缓存文件，最终保存在new目录。

最后一个`extract`目录，开发中建议将它用作单独读取的操作目录，仍是原子化处理。



## files/fetchmailrc
fetchmail的示例配置文件，支持IMAP协议。

### poll imap.example.com

指定要轮询（检查）的邮件服务器主机名。

### proto IMAP

使用 IMAP 协议（而非 POP3）与服务器通信。

### user user@example.com

登录邮箱的用户名（完整的电子邮件地址）。

### password example

对应账户的IMAP服务授权码

### ssl

启用 SSL/TLS 加密连接，确保通信安全。

### sslcertck

启用 SSL 证书验证，防止中间人攻击。

### sslcertfile /etc/ssl/certs/ca-certificates.crt

指定受信任的 CA 证书包路径，用于验证服务器证书的有效性（通常为系统默认 CA 证书库）。

### keep

保留服务器上的原始邮件（即下载后不删除服务器副本）。若需删除，请移除此行或替换为 fetchall + no keep。

### limit 100000

注释掉的选项，用于限制仅下载小于 100,000 字节（约 100 KB）的邮件。如需启用，请取消注释并根据需要调整数值。

### mda /usr/bin/fetchmail_deliver.sh

指定邮件投递代理（MDA），所有成功获取的邮件将通过此脚本处理（例如：传递给本地 MTA、存入 Maildir 或触发其他自动化操作）。



## files/update_fetchmailrc.sh

对上述示例的配置文件做修改的处理脚本，具体用法参考注释。




## patches/001-imap-id-support-for-netease-163.patch

这个patch是解决网易域邮箱的登录问题。

问题根因参考网页客服链接


https://help.mail.163.com/faqDetail.do?code=d7a5dc8471cd0c0e8b4b8f4f8e49998b374173cfe9171305fa1ce630d7f67ac2eda07326646e6eb0


具体是因为网易需要客户端表明相关“身份”信息才可以允许连接，

否则将会返回如下报错：Unsafe Login. Please contact kefu@188.com for help。

fetchmail在登录时，默认是没有添加该身份识别信息的。

为了修复该问题，我对fetchmail做了patch。做法是在检测到是网易域邮箱时，

在登录时发送符合 RFC 2971 的 ID 扩展命令格式，示例

```
a001 ID ("name" "fetchmail" "version" "6.4.39" "vendor" "OpenWRT")
```

向服务器声明客户端信息，登录问题就可以解决了。

 RFC 2971 标准请查看 `https://www.ietf.org/rfc/rfc2971.txt`



## Makefile

fetchmail源码地址

https://sourceforge.net/projects/fetchmail/

注意：

该文件fetchmail的源码版本是停止维护了的，由于我的OpenWRT版本是2102的，openssl版本不适合最新的fetchmail，会导致编译报错。

虽不是最新的fetchmail版本，但基本邮件功能可用。


# 处理接收的邮件信息

OpenWRT有专门的处理软件mblaze。组件路径，打开

```
Mail  --->
    mblaze... Unix utilities to deal with Maildir
```

通过文件 `files/fetchmail_deliver.sh` 处理后，处理邮件时，建议移动到`extract`目录一封一封地处理。

使用以下命令行，需要注意的是，`命令行工具是对整个目录所以文件遍历操作的`。

```
# 提取发件人From
maddr -a from /tmp/maildir/extract/ 2>/dev/null | head -n 1

# 提取收件人To
maddr -a from /tmp/maildir/extract/ 2>/dev/null | sed -n '2p'

# 提取主题Subject
mhdr -h subject /tmp/maildir/extract/ 2>/dev/null
mhdr -h subject /tmp/maildir/extract/

# 提取正文Body (text/plain)
mshow -O /tmp/maildir/extract/ 2
```


