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
| 409 | 重复提交或资源冲突 |
| 500 | 服务端异常 |

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

响应字段包含：`id`、`departmentId`、`departmentName`、`name`、`title`、`specialty`、`introduction`。

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
- 就诊人不属于当前账号：`400`

## 预约记录查询

`GET /api/appointments?userId=2`

## 取消预约

`POST /api/appointments/{appointmentId}/cancel?userId=2`

规则：预约创建后 30 分钟内可取消，超过后不可取消。

## 搜索

`GET /api/search?keyword=王`

返回匹配的科室和医生。

## 管理员统计

`GET /api/admin/statistics`

返回每日预约量和热门科室。

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
