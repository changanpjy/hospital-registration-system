# 前端项目说明

## 技术栈

- Vue 3
- TypeScript
- Vue SFC
- Vite

## 主要功能

- 登录、注册，支持手机号或邮箱注册。
- 挂号预约，按科室、医生、号源、就诊人完成预约。
- 搜索科室或医生，清空搜索后自动恢复全部科室。
- 预约成功页，展示预约号、就诊信息和注意事项。
- 就诊人管理，支持新增本人或家属就诊信息。
- 我的预约，支持查看预约状态和取消预约。
- 个人中心，默认只读，点击“编辑信息”后可修改用户名、手机号和邮箱。
- 管理统计，仅管理员可见，可查看预约统计并维护全部科室下的医生排班号源。
- 用户管理，仅管理员可见，可查看用户列表并启用或禁用用户。

普通用户不会看到“管理统计”和“用户管理”模块。

## 目录结构

```text
src
├── api.ts                 API 请求封装
├── App.vue                应用入口和状态组织
├── constants.ts           字典和导航配置
├── main.ts                Vue 挂载入口
├── styles.css             全局样式
├── types.ts               TypeScript 类型定义
├── components             通用组件
└── views                  页面级组件
```

## 启动前端

```bash
npm install
npm run dev
```

默认访问地址：

```text
http://localhost:5173
```

开发服务会把 `/api` 请求代理到后端服务。请先启动后端：

```text
http://localhost:8081
```

## 常用命令

类型检查：

```bash
npm run typecheck
```

生产构建：

```bash
npm run build
```

预览构建结果：

```bash
npm run preview
```

## 环境变量

默认请求路径为 `/api`。如需直接指定后端地址，可设置：

```bash
set VITE_API_BASE=http://localhost:8081/api
```

PowerShell 示例：

```powershell
$env:VITE_API_BASE="http://localhost:8081/api"
npm run dev
```

## 演示账号

- 管理员：`admin / 123456`
- 患者：`zhangsan / 123456`
- 患者：`lisi / 123456`
- 患者：`wangwu / 123456`
- 患者：`chenqian / 123456`
- 患者：`wuyue / 123456`

## 主流程

1. 使用患者账号登录。
2. 在“就诊人”中维护本人或家属信息。
3. 在“挂号预约”中选择科室、医生和号源。
4. 选择就诊人并提交预约。
5. 进入预约成功页查看预约号和就诊信息。
6. 在“我的预约”中查看或取消预约。
7. 在“个人中心”点击“编辑信息”维护账号基础信息。
8. 使用管理员账号登录后，可进入“管理统计”和“用户管理”。
