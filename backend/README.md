# 后端服务说明

## 技术栈

- Java 8
- Spring Boot 2.6.13
- Spring MVC RESTful API
- MyBatis
- MySQL 8.x
- Bean Validation

## 主要功能

- 用户注册、登录，支持用户名、手机号或邮箱登录。
- 个人信息维护，用户可修改用户名、手机号和邮箱。
- 就诊人管理，一个账号可维护多个本人或家属就诊人。
- 科室、医生、未来 7 天号源查询。
- 提交预约、防止重复预约、号源原子扣减。
- 预约成功后生成预约号，并将 `notice_sent` 标记为已发送通知。
- 预约创建后 30 分钟内可取消，取消后返还号源。
- 管理员统计预约数据、维护医生排班号源。
- 管理员用户管理，可查看用户列表并启用或禁用用户；当前管理员账号不能被禁用。

## 目录结构

```text
src/main/java/com/hospital/backend
├── common       统一响应、业务异常、全局异常处理
├── config       Web 跨域配置
├── controller   REST API 控制层
├── dto          请求参数对象
├── entity       数据实体
├── mapper       MyBatis 数据访问层
└── service      业务逻辑层
```

## 初始化数据库

先确保 MySQL 已启动，然后在 `backend` 目录执行：

```bash
mysql -uroot -p < 数据库初始化脚本/init.sql
```

脚本会创建 `hospital_registration` 数据库、核心业务表、演示账号、科室、医生和未来 7 天号源。

如果本机数据库账号或密码不同，请修改：

```properties
spring.datasource.username=root
spring.datasource.password=123456
```

配置文件位置：

```text
src/main/resources/application.properties
```

## 启动后端

```bash
mvn spring-boot:run
```

默认地址：

```text
http://localhost:8081
```

## 运行测试

```bash
mvn test
```

## 默认账号

- 管理员：`admin / 123456`
- 患者：`zhangsan / 123456`
- 患者：`lisi / 123456`

## 核心接口

- `POST /api/auth/login`：登录
- `POST /api/auth/register`：注册
- `PUT /api/users/{userId}`：修改个人信息
- `GET /api/departments`：科室列表
- `GET /api/departments/{departmentId}/doctors`：科室下医生列表
- `GET /api/doctors/{doctorId}/schedules`：医生号源排班
- `GET /api/patients`：就诊人列表
- `POST /api/patients`：新增就诊人
- `POST /api/appointments`：提交预约
- `GET /api/appointments`：预约记录查询
- `POST /api/appointments/{appointmentId}/cancel`：取消预约
- `GET /api/admin/statistics`：管理员统计
- `PUT /api/admin/schedules/{scheduleId}`：管理员修改排班
- `GET /api/admin/users`：管理员用户列表
- `PUT /api/admin/users/{userId}/status`：管理员启用或禁用用户

完整接口示例见：

```text
../docs/API文档.md
```

## 关键业务规则

- 当天上午号源需在 11:30 前预约，当天下午号源需在 17:30 前预约。
- 同一就诊人同一科室同一天只能预约一次。
- 号源扣减使用事务和条件更新，避免并发超卖。
- 预约创建后 30 分钟内允许取消，超过后拒绝取消。
- 手机号如填写，必须是以 1 开头的 11 位手机号。
- 管理员接口会校验操作者角色，普通用户不可执行管理操作。
