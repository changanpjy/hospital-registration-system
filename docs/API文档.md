# API 文档

统一响应格式：

```json
{
  "code": 200,
  "message": "success",
  "data": {}
}
```

错误响应示例：

```json
{
  "code": 409,
  "message": "号源已被约满，请选择其他时段",
  "data": null
}
```

## 状态码说明

| code | 说明 |
| --- | --- |
| 200 | 成功 |
| 400 | 参数或业务规则错误 |
| 401 | 登录失败 |
| 403 | 权限不足 |
| 409 | 重复提交或资源冲突 |
| 500 | 服务端异常 |

## 接口列表

| 模块 | 方法 | 接口 | 说明 |
| --- | --- | --- | --- |
| 认证 | POST | `/api/auth/login` | 登录 |
| 认证 | POST | `/api/auth/register` | 注册 |
| 科室 | GET | `/api/departments` | 科室列表，可按关键字筛选 |
| 医生 | GET | `/api/departments/{departmentId}/doctors` | 查询科室下医生 |
| 号源 | GET | `/api/doctors/{doctorId}/schedules` | 查询医生未来号源排班 |
| 就诊人 | GET | `/api/patients` | 查询当前账号就诊人 |
| 就诊人 | POST | `/api/patients` | 新增就诊人 |
| 用户 | PUT | `/api/users/{userId}` | 修改个人信息 |
| 预约 | POST | `/api/appointments` | 提交预约 |
| 预约 | GET | `/api/appointments` | 查询预约记录 |
| 预约 | POST | `/api/appointments/{appointmentId}/cancel` | 取消预约 |
| 搜索 | GET | `/api/search` | 搜索科室和医生 |
| 管理 | GET | `/api/admin/statistics` | 管理员统计 |
| 管理 | PUT | `/api/admin/schedules/{scheduleId}` | 管理员修改排班 |
| 管理 | GET | `/api/admin/users` | 管理员查询用户列表 |
| 管理 | PUT | `/api/admin/users/{userId}/status` | 管理员启用或禁用用户 |

## 登录

`POST /api/auth/login`

请求：

```json
{
  "account": "zhangsan",
  "password": "123456"
}
```

响应：

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 2,
    "username": "zhangsan",
    "phone": "13811111111",
    "email": "zhangsan@example.com",
    "role": "PATIENT"
  }
}
```

## 注册

`POST /api/auth/register`

手机号注册请求：

```json
{
  "username": "wangwu",
  "phone": "13833333333",
  "password": "123456"
}
```

邮箱注册请求：

```json
{
  "username": "wangwu",
  "email": "wangwu@example.com",
  "password": "123456"
}
```

注册时用户名必填；手机号和邮箱二选一作为联系方式。登录时 `account` 可填写用户名、手机号或邮箱。数据库对用户名有唯一约束。

## 科室列表

`GET /api/departments?keyword=内科`

响应：

```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "name": "内科",
      "description": "主要负责常见内科疾病、慢性病、呼吸系统和消化系统相关疾病的诊疗。"
    }
  ]
}
```

## 科室下医生列表

`GET /api/departments/{departmentId}/doctors`

响应：

```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "departmentId": 1,
      "departmentName": "内科",
      "name": "王建国",
      "title": "主任医师",
      "specialty": "高血压、糖尿病、慢性支气管炎",
      "introduction": "从事内科临床工作多年，擅长慢性病诊疗。",
      "status": 1
    }
  ]
}
```

## 医生排班查询

`GET /api/doctors/{doctorId}/schedules`

返回未来 7 天内可展示的号源；如果当前时间是上午，会包含今天下午号源，今天上午号源不展示。

响应：

```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "doctorId": 1,
      "doctorName": "王建国",
      "departmentId": 1,
      "departmentName": "内科",
      "workDate": "2026-05-28",
      "period": "MORNING",
      "totalCount": 15,
      "availableCount": 15,
      "status": "AVAILABLE"
    }
  ]
}
```

## 就诊人列表

`GET /api/patients?userId=2`

响应：

```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "userId": 2,
      "name": "张三",
      "idCard": "110101199801011234",
      "phone": "13811111111",
      "gender": 1,
      "birthDate": "1998-01-01"
    }
  ]
}
```

## 新增就诊人

`POST /api/patients`

请求：

```json
{
  "userId": 2,
  "name": "张小明",
  "idCard": "110101201005051234",
  "phone": "13811111111",
  "gender": 1,
  "birthDate": "2010-05-05"
}
```

响应：

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 4,
    "userId": 2,
    "name": "张小明",
    "idCard": "110101201005051234",
    "phone": "13811111111",
    "gender": 1,
    "birthDate": "2010-05-05"
  }
}
```

## 提交预约

`POST /api/appointments`

请求：

```json
{
  "userId": 2,
  "patientId": 1,
  "scheduleId": 3
}
```

响应：

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "appointmentNo": "YYGH20260527153001A1B2C3",
    "patientName": "张三",
    "departmentName": "内科",
    "doctorName": "王建国",
    "visitDate": "2026-05-28",
    "period": "MORNING",
    "status": "WAITING",
    "noticeSent": 1
  }
}
```

业务错误：

- 同一就诊人同一科室同一天重复预约：`409`
- 号源已约满或停诊：`400` 或 `409`
- 当天上午超过 11:30 或当天下午超过 17:30 后提交预约：`400`
- 就诊人不属于当前账号：`400`

## 修改个人信息

`PUT /api/users/{userId}`

请求：

```json
{
  "username": "zhangsan",
  "phone": "13811111111",
  "email": "zhangsan@example.com"
}
```

响应：

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 2,
    "username": "zhangsan",
    "phone": "13811111111",
    "email": "zhangsan@example.com",
    "role": "PATIENT",
    "status": 1
  }
}
```

规则：

- 用户名不能为空。
- 手机号如填写，必须是以 1 开头的 11 位手机号。
- 手机号和邮箱至少保留一个。
- 用户名、手机号、邮箱不能和其他账号重复。
- 前端个人中心默认只读，点击“编辑信息”后才允许修改并保存。

## 预约记录查询

`GET /api/appointments?userId=2`

响应：

```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "appointmentNo": "YYGH20260527153001A1B2C3",
      "patientName": "张三",
      "departmentName": "内科",
      "doctorName": "王建国",
      "visitDate": "2026-05-28",
      "period": "MORNING",
      "status": "WAITING",
      "noticeSent": 1,
      "cancelTime": null
    }
  ]
}
```

## 管理员用户列表

`GET /api/admin/users?adminId=1`

响应：

```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "username": "admin",
      "phone": "13800000000",
      "email": "admin@hospital.com",
      "role": "ADMIN",
      "status": 1
    },
    {
      "id": 2,
      "username": "zhangsan",
      "phone": "13811111111",
      "email": "zhangsan@example.com",
      "role": "PATIENT",
      "status": 1
    }
  ]
}
```

## 管理员修改用户状态

`PUT /api/admin/users/{userId}/status`

请求：

```json
{
  "adminId": 1,
  "status": 0
}
```

响应：

```json
{
  "code": 200,
  "message": "success",
  "data": null
}
```

规则：

- 仅管理员可操作。
- `status` 只能为 `0` 禁用或 `1` 启用。
- 不能禁用当前管理员账号。

## 取消预约

`POST /api/appointments/{appointmentId}/cancel?userId=2`

规则：预约创建后 30 分钟内可取消，超过后不可取消。

响应：

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "appointmentNo": "YYGH20260527153001A1B2C3",
    "patientName": "张三",
    "departmentName": "内科",
    "doctorName": "王建国",
    "visitDate": "2026-05-28",
    "period": "MORNING",
    "status": "CANCELLED",
    "noticeSent": 1,
    "cancelTime": "2026-05-27T15:45:00"
  }
}
```

## 搜索

`GET /api/search?keyword=王`

返回匹配的科室和医生。

响应：

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "departments": [],
    "doctors": [
      {
        "id": 1,
        "departmentId": 1,
        "departmentName": "内科",
        "name": "王建国",
        "title": "主任医师",
        "specialty": "高血压、糖尿病、慢性支气管炎"
      }
    ]
  }
}
```

## 管理员统计

`GET /api/admin/statistics`

返回每日预约量和热门科室。

响应：

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "totalAppointments": 20,
    "waitingAppointments": 15,
    "cancelledAppointments": 3,
    "completedAppointments": 2,
    "dailyVisits": [
      {
        "visitDate": "2026-05-30",
        "total": 6
      }
    ],
    "departmentRanks": [
      {
        "departmentName": "内科",
        "total": 8
      }
    ]
  }
}
```

## 管理员修改排班

`PUT /api/admin/schedules/{scheduleId}`

请求：

```json
{
  "totalCount": 20,
  "availableCount": 18,
  "status": "AVAILABLE"
}
```

响应：

```json
{
  "code": 200,
  "message": "success",
  "data": null
}
```
