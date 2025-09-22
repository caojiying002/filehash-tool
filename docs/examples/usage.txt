# FilehHash 使用示例

## 基本使用示例

### 1. 计算文件的默认哈希值

# 计算MD5哈希值（默认）
$ filehash document.pdf
MD5 (5d41402abc4b2a76b9719d911017c592) = document.pdf

# 显式指定MD5算法
$ filehash -m document.pdf
MD5 (5d41402abc4b2a76b9719d911017c592) = document.pdf

$ filehash --md5 document.pdf
MD5 (5d41402abc4b2a76b9719d911017c592) = document.pdf

### 2. 使用其他算法

# SHA1哈希值
$ filehash -s document.pdf
SHA1 (aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d) = document.pdf

$ filehash --sha1 document.pdf
SHA1 (aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d) = document.pdf

# SHA256哈希值
$ filehash -S document.pdf
SHA256 (e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855) = document.pdf

$ filehash --sha256 document.pdf
SHA256 (e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855) = document.pdf

### 3. 计算所有支持的哈希值

$ filehash -a document.pdf
MD5 (5d41402abc4b2a76b9719d911017c592) = document.pdf
SHA1 (aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d) = document.pdf
SHA256 (e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855) = document.pdf

$ filehash --all document.pdf
MD5 (5d41402abc4b2a76b9719d911017c592) = document.pdf
SHA1 (aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d) = document.pdf
SHA256 (e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855) = document.pdf

## 批量处理示例

### 4. 多个文件

$ filehash file1.txt file2.txt file3.txt
MD5 (d41d8cd98f00b204e9800998ecf8427e) = file1.txt
MD5 (c4ca4238a0b923820dcc509a6f75849b) = file2.txt
MD5 (c81e728d9d4c2f636f067f89cc14862c) = file3.txt

$ filehash -S file1.txt file2.txt file3.txt
SHA256 (e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855) = file1.txt
SHA256 (6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b) = file2.txt
SHA256 (d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35) = file3.txt

### 5. 使用通配符批量处理

# 处理所有.txt文件
$ filehash *.txt
MD5 (d41d8cd98f00b204e9800998ecf8427e) = empty.txt
MD5 (5d41402abc4b2a76b9719d911017c592) = hello.txt
MD5 (c4ca4238a0b923820dcc509a6f75849b) = test.txt

# 所有.log文件的SHA256
$ filehash -S *.log
SHA256 (e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855) = access.log
SHA256 (4dff4ea340f0a823f15d3f4f01ab62eae0e5da579ccb851f8db9dfe84c58b2b37) = error.log

# 处理指定路径下所有文件
$ filehash /tmp/downloads/*
MD5 (098f6bcd4621d373cade4e832627b4f6) = /tmp/downloads/archive.zip
MD5 (5d41402abc4b2a76b9719d911017c592) = /tmp/downloads/readme.txt

## 实际使用场景示例

### 6. 下载文件完整性验证

# 下载文件后验证完整性
$ wget https://example.com/software.tar.gz
$ filehash -S software.tar.gz
SHA256 (a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3) = software.tar.gz

# 与官方提供的校验和对比
$ echo "a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3  software.tar.gz" | sha256sum -c
software.tar.gz: OK

### 7. 备份验证

# 备份前记录所有哈希值
$ filehash -a important_document.docx > backup_checksums.txt
$ cat backup_checksums.txt
MD5 (5d41402abc4b2a76b9719d911017c592) = important_document.docx
SHA1 (aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d) = important_document.docx
SHA256 (e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855) = important_document.docx

# 恢复后验证完整性
$ filehash -a restored_document.docx
MD5 (5d41402abc4b2a76b9719d911017c592) = restored_document.docx
SHA1 (aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d) = restored_document.docx
SHA256 (e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855) = restored_document.docx

### 8. 重复文件检测

# 比较两个文件是否相同
$ filehash -S original.jpg copy.jpg
SHA256 (a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3) = original.jpg
SHA256 (a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3) = copy.jpg

# 批量检测重复文件，按哈希值排序
$ filehash *.jpg | sort -k2
SHA256 (a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3) = image1.jpg
SHA256 (a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3) = image1_copy.jpg
SHA256 (b84ed8e8c8e2f0d8cd74c1b85b67e5c8e7d4b1f3c8f2d5e3c7b4e8f1a9c2d5e3) = image2.jpg

## 错误处理示例

### 9. 文件不存在错误

$ filehash nonexistent.txt
Error: Cannot open file 'nonexistent.txt'

$ echo $?
1

### 10. 权限错误

$ filehash /root/private.txt
Error: Cannot access file '/root/private.txt'

$ echo $?
1

### 11. 目录输入错误

$ filehash /tmp
Error: '/tmp' is a directory, not a file
Error: Cannot access file '/tmp'

$ echo $?
1

### 12. 无参数错误

$ filehash
Usage: filehash [OPTIONS] FILE...
Calculate hash values for files

Options:
  -m, --md5      Calculate MD5 hash (default)
  -s, --sha1     Calculate SHA1 hash
  -S, --sha256   Calculate SHA256 hash
  -a, --all      Calculate all hash types
  -h, --help     Show this help message
  -v, --version  Show version information

$ echo $?
1

## 系统帮助和版本信息

### 13. 显示帮助信息

$ filehash -h
Usage: filehash [OPTIONS] FILE...
Calculate hash values for files

Options:
  -m, --md5      Calculate MD5 hash (default)
  -s, --sha1     Calculate SHA1 hash
  -S, --sha256   Calculate SHA256 hash
  -a, --all      Calculate all hash types
  -h, --help     Show this help message
  -v, --version  Show version information

Examples:
  filehash file.txt                # Calculate MD5 hash
  filehash -s file.txt             # Calculate SHA1 hash
  filehash -S file.txt             # Calculate SHA256 hash
  filehash -a file.txt             # Calculate all hash types
  filehash *.txt                   # Calculate MD5 for all .txt files

### 14. 显示版本信息

$ filehash -v
filehash 1.0.0
A simple file hash calculator supporting MD5, SHA1, and SHA256

$ filehash --version
filehash 1.0.0
A simple file hash calculator supporting MD5, SHA1, and SHA256

## 高级用法示例

### 15. 大文件处理

# 大文件推荐使用SHA256（更安全但相对较慢）
$ filehash -S large_archive.tar.gz
SHA256 (a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3) = large_archive.tar.gz

# 如果需要快速检验可以使用MD5（速度较快但安全性较低）
$ filehash -m large_archive.tar.gz
MD5 (5d41402abc4b2a76b9719d911017c592) = large_archive.tar.gz

### 16. 批量处理技巧

# 结合find命令处理大量文件
$ find /large/directory -name "*.txt" | head -100 | xargs filehash -S

# 使用循环显示处理进度
$ for file in *.bin; do echo "Processing $file..."; filehash -S "$file"; done

### 17. 输出重定向

# 保存结果到文件
$ filehash -a *.txt > all_checksums.txt

# 追加到现有文件
$ filehash -S new_file.dat >> all_checksums.txt

# 只保存哈希值，不保存文件名
$ filehash document.pdf | cut -d' ' -f2 | tr -d '()'

### 18. 与其他工具配合

# 结合grep查找特定哈希值
$ filehash *.txt | grep "d41d8cd98f00b204e9800998ecf8427e"

# 生成校验和文件格式
$ filehash -S *.txt | sed 's/SHA256 (\([^)]*\)) = \(.*\)/\1  \2/' > SHA256SUMS

# 验证校验和文件
$ sha256sum -c SHA256SUMS

## 性能优化建议

### 19. 算法选择建议

# 对于快速校验，使用MD5（最快）
$ time filehash -m large_file.bin

# 对于安全校验，使用SHA256（推荐）
$ time filehash -S large_file.bin

# 对于兼容性考虑，使用SHA1（中等）
$ time filehash -s large_file.bin

### 20. 批量处理优化

# 避免在循环中频繁调用
# 好的做法：
$ filehash *.log

# 避免的做法：
# for file in *.log; do filehash "$file"; done

## 常见用例总结

1. **文件完整性验证**: 下载后验证文件是否损坏
2. **备份验证**: 确保备份文件与原文件一致
3. **重复文件检测**: 通过哈希值识别重复文件
4. **文件监控**: 定期检查重要文件是否被篡改
5. **数据迁移验证**: 确保数据传输过程中的完整性
6. **软件分发**: 为软件包提供校验和
7. **法证分析**: 计算证据文件的哈希值
8. **版本控制**: 检测文件内容是否发生变化