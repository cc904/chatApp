#!/bin/bash

# 创建会话初始化目录（如果不存在）
mkdir -p scripts

echo "正在初始化项目上下文..."
echo "项目概要已生成在 docs/project_summary.md"
echo ""
echo "使用提示："
echo "1. 在新的AI对话中，首先请求AI阅读 docs/project_summary.md"
echo "2. 简明扼要地描述您当前的开发任务"
echo ""
echo "复制以下文本作为新会话的开始："
echo "------------------------------"
echo "我正在开发一个Flutter WhatsApp克隆项目。请先阅读 docs/project_summary.md 文件了解项目结构，然后我们开始讨论[您的具体任务]。" 