# 后端启动说明

## 技术栈

- Java 8+ / Spring Boot 2.6.13
- MyBatis
- MySQL 8.x

## 启动步骤

1. 创建并初始化数据库：

```bash
mysql -uroot -p < 数据库初始化脚本/init.sql
```

2. 修改 `src/main/resources/application.properties` 中的数据库账号密码：

```properties
spring.datasource.username=root
spring.datasource.password=123456
```

3. 启动后端：

```bash
mvn spring-boot:run
```

默认端口：`8081`。

## 默认账号

- 患者：`zhangsan / 123456`
- 患者：`lisi / 123456`
- 管理员：`admin / 123456`
