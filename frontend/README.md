# 前端启动说明

## 技术栈

- Vue 3
- TypeScript / Vue SFC
- Vite

## 启动步骤

```bash
npm install
npm run dev
```

默认访问地址：`http://localhost:5173`。

Vite 已将 `/api` 代理到 `http://localhost:8081`。如需修改后端地址，可设置：

```bash
set VITE_API_BASE=http://localhost:8081/api
```

## 主要功能

- 患者登录
- 科室与医生浏览
- 未来 7 天号源查看
- 就诊人新增与选择
- 提交预约并进入预约成功页，展示预约详情、预约号和注意事项
- 查看和取消预约
- 管理员统计面板
