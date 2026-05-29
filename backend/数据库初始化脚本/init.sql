-- =========================================================
-- 在线挂号系统数据库初始化脚本
-- 数据库名称：hospital_registration
-- =========================================================

-- 1. 创建数据库
CREATE DATABASE IF NOT EXISTS hospital_registration
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE hospital_registration;

-- 2. 删除旧表，注意顺序：先删子表，再删主表
DROP TABLE IF EXISTS appointment;
DROP TABLE IF EXISTS schedule;
DROP TABLE IF EXISTS doctor;
DROP TABLE IF EXISTS department;
DROP TABLE IF EXISTS patient;
DROP TABLE IF EXISTS users;

-- =========================================================
-- 3. 用户表
-- 说明：用于患者和管理员登录
-- role：PATIENT 患者，ADMIN 管理员
-- =========================================================
CREATE TABLE users (
                       id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
                       username VARCHAR(50) NOT NULL COMMENT '用户名',
                       phone VARCHAR(20) DEFAULT NULL COMMENT '手机号',
                       email VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
                       password VARCHAR(100) NOT NULL COMMENT '密码，演示项目中可先使用明文，后续可改为加密',
                       role VARCHAR(20) NOT NULL DEFAULT 'PATIENT' COMMENT '角色：PATIENT-患者，ADMIN-管理员',
                       status TINYINT NOT NULL DEFAULT 1 COMMENT '账号状态：1-正常，0-禁用',
                       create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                       update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

                       -- 唯一索引：保证用户名、手机号、邮箱不会重复注册
                       UNIQUE KEY uk_users_username (username),
                       UNIQUE KEY uk_users_phone (phone),
                       UNIQUE KEY uk_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- =========================================================
-- 4. 就诊人表
-- 说明：一个账号可以添加多个就诊人
-- =========================================================
CREATE TABLE patient (
                         id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '就诊人ID',
                         user_id BIGINT NOT NULL COMMENT '所属用户ID',
                         name VARCHAR(50) NOT NULL COMMENT '就诊人姓名',
                         id_card VARCHAR(18) NOT NULL COMMENT '身份证号',
                         phone VARCHAR(20) NOT NULL COMMENT '就诊人手机号',
                         gender TINYINT DEFAULT NULL COMMENT '性别：1-男，2-女',
                         birth_date DATE DEFAULT NULL COMMENT '出生日期',
                         create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                         update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

                         -- 唯一索引：身份证号唯一，避免同一就诊人重复录入
                         UNIQUE KEY uk_patient_id_card (id_card),
                         -- 普通索引：支持按账号快速查询该账号下的就诊人
                         KEY idx_patient_user_id (user_id),

                         CONSTRAINT fk_patient_user
                             FOREIGN KEY (user_id) REFERENCES users(id)
                                 ON DELETE CASCADE
                                 ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='就诊人表';

-- =========================================================
-- 5. 科室表
-- =========================================================
CREATE TABLE department (
                            id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '科室ID',
                            name VARCHAR(50) NOT NULL COMMENT '科室名称',
                            description VARCHAR(500) DEFAULT NULL COMMENT '科室介绍',
                            status TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1-启用，0-停用',
                            create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                            update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

                            -- 唯一索引：科室名称唯一，避免重复维护科室
                            UNIQUE KEY uk_department_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='科室表';

-- =========================================================
-- 6. 医生表
-- 说明：医生属于某一个科室
-- =========================================================
CREATE TABLE doctor (
                        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '医生ID',
                        department_id BIGINT NOT NULL COMMENT '所属科室ID',
                        name VARCHAR(50) NOT NULL COMMENT '医生姓名',
                        title VARCHAR(50) NOT NULL COMMENT '职称，如主任医师、副主任医师、主治医师',
                        specialty VARCHAR(255) DEFAULT NULL COMMENT '专长',
                        introduction TEXT DEFAULT NULL COMMENT '医生简介',
                        status TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1-正常，0-停诊/停用',
                        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

                        -- 普通索引：支持按科室加载医生列表
                        KEY idx_doctor_department_id (department_id),
                        -- 普通索引：支持按医生姓名搜索
                        KEY idx_doctor_name (name),

                        CONSTRAINT fk_doctor_department
                            FOREIGN KEY (department_id) REFERENCES department(id)
                                ON DELETE RESTRICT
                                ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='医生表';

-- =========================================================
-- 7. 号源/排班表
-- 说明：一个医生在某一天上午或下午对应一条号源记录
-- period：MORNING 上午，AFTERNOON 下午
-- status：AVAILABLE 可预约，FULL 已约满，STOPPED 停诊
-- =========================================================
CREATE TABLE schedule (
                          id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '号源ID',
                          doctor_id BIGINT NOT NULL COMMENT '医生ID',
                          work_date DATE NOT NULL COMMENT '出诊日期',
                          period VARCHAR(20) NOT NULL COMMENT '时段：MORNING-上午，AFTERNOON-下午',
                          total_count INT NOT NULL COMMENT '总号源数量',
                          available_count INT NOT NULL COMMENT '剩余可预约数量',
                          status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE' COMMENT '状态：AVAILABLE-可预约，FULL-已约满，STOPPED-停诊',
                          create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                          update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

                          -- 唯一索引：保证同一医生同一天同一时段只有一条号源
                          UNIQUE KEY uk_schedule_doctor_date_period (doctor_id, work_date, period),
                          -- 普通索引：支持按医生查询未来号源
                          KEY idx_schedule_doctor_id (doctor_id),
                          -- 普通索引：支持按日期筛选号源
                          KEY idx_schedule_work_date (work_date),
                          -- 普通索引：支持按可预约、约满、停诊状态筛选
                          KEY idx_schedule_status (status),

                          CONSTRAINT fk_schedule_doctor
                              FOREIGN KEY (doctor_id) REFERENCES doctor(id)
                                  ON DELETE CASCADE
                                  ON UPDATE CASCADE,

                          CONSTRAINT chk_schedule_count
                              CHECK (total_count >= 0 AND available_count >= 0 AND available_count <= total_count)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='号源排班表';

-- =========================================================
-- 8. 预约记录表
-- 说明：记录患者提交的挂号预约
-- status：WAITING 待就诊，CANCELLED 已取消，COMPLETED 已完成
-- 同一就诊人同一科室同一天只能预约一次，通过唯一索引实现基础限制
-- =========================================================
CREATE TABLE appointment (
                             id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '预约ID',
                             appointment_no VARCHAR(50) NOT NULL COMMENT '唯一预约号',
                             user_id BIGINT NOT NULL COMMENT '预约账号ID',
                             patient_id BIGINT NOT NULL COMMENT '就诊人ID',
                             department_id BIGINT NOT NULL COMMENT '科室ID',
                             doctor_id BIGINT NOT NULL COMMENT '医生ID',
                             schedule_id BIGINT NOT NULL COMMENT '号源ID',
                             visit_date DATE NOT NULL COMMENT '就诊日期',
                             period VARCHAR(20) NOT NULL COMMENT '就诊时段：MORNING-上午，AFTERNOON-下午',
                             status VARCHAR(20) NOT NULL DEFAULT 'WAITING' COMMENT '状态：WAITING-待就诊，CANCELLED-已取消，COMPLETED-已完成',
                             notice_sent TINYINT NOT NULL DEFAULT 0 COMMENT '是否已发送通知：0-未发送，1-已发送',
                             cancel_time DATETIME DEFAULT NULL COMMENT '取消时间',
                             create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '预约创建时间',
                             update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

                             -- 唯一索引：保证预约号全局唯一
                             UNIQUE KEY uk_appointment_no (appointment_no),
                             -- 唯一索引：防止同一就诊人同一科室同一天重复预约
                             UNIQUE KEY uk_patient_department_date (patient_id, department_id, visit_date),
                             -- 普通索引：支持“我的预约”按账号查询
                             KEY idx_appointment_user_id (user_id),
                             -- 普通索引：支持按就诊人追踪预约
                             KEY idx_appointment_patient_id (patient_id),
                             -- 普通索引：支持按号源追踪预约记录
                             KEY idx_appointment_schedule_id (schedule_id),
                             -- 普通索引：支持按预约状态筛选
                             KEY idx_appointment_status (status),
                             -- 普通索引：支持按就诊日期统计和查询
                             KEY idx_appointment_visit_date (visit_date),

                             CONSTRAINT fk_appointment_user
                                 FOREIGN KEY (user_id) REFERENCES users(id)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE,

                             CONSTRAINT fk_appointment_patient
                                 FOREIGN KEY (patient_id) REFERENCES patient(id)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE,

                             CONSTRAINT fk_appointment_department
                                 FOREIGN KEY (department_id) REFERENCES department(id)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE,

                             CONSTRAINT fk_appointment_doctor
                                 FOREIGN KEY (doctor_id) REFERENCES doctor(id)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE,

                             CONSTRAINT fk_appointment_schedule
                                 FOREIGN KEY (schedule_id) REFERENCES schedule(id)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约记录表';

-- =========================================================
-- 9. 初始化用户数据
-- 说明：
-- 管理员账号：admin / 123456
-- 患者账号：zhangsan / 123456
-- 患者账号：lisi / 123456
-- 患者账号：wangwu / 123456
-- 患者账号：chenqian / 123456
-- 患者账号：wuyue / 123456
-- =========================================================
INSERT INTO users (id, username, phone, email, password, role, status) VALUES
                                                                           (1, 'admin', '13800000000', 'admin@hospital.com', '123456', 'ADMIN', 1),
                                                                           (2, 'zhangsan', '13811111111', 'zhangsan@example.com', '123456', 'PATIENT', 1),
                                                                           (3, 'lisi', '13822222222', 'lisi@example.com', '123456', 'PATIENT', 1),
                                                                           (4, 'wangwu', '13833333333', 'wangwu@example.com', '123456', 'PATIENT', 1),
                                                                           (5, 'chenqian', '13844444444', 'chenqian@example.com', '123456', 'PATIENT', 1),
                                                                           (6, 'wuyue', '13855555555', 'wuyue@example.com', '123456', 'PATIENT', 1);

-- =========================================================
-- 10. 初始化就诊人数据
-- =========================================================
INSERT INTO patient (id, user_id, name, id_card, phone, gender, birth_date) VALUES
                                                                                (1, 2, '张三', '110101199801011234', '13811111111', 1, '1998-01-01'),
                                                                                (2, 2, '张小明', '110101201005051234', '13811111111', 1, '2010-05-05'),
                                                                                (3, 3, '李四', '110101199902021234', '13822222222', 1, '1999-02-02'),
                                                                                (4, 2, '王小雨', '110101199503031111', '13830000001', 2, '1995-03-03'),
                                                                                (5, 3, '孙浩', '110101199604041112', '13830000002', 1, '1996-04-04'),
                                                                                (6, 4, '王五', '110101198805051235', '13833333333', 1, '1988-05-05'),
                                                                                (7, 5, '赵晨', '110101199704041112', '13830000004', 1, '1997-04-04'),
                                                                                (8, 5, '钱嘉', '110101199705051113', '13830000003', 2, '1997-05-05'),
                                                                                (9, 6, '吴越', '110101199806061114', '13855555555', 1, '1998-06-06'),
                                                                                (10, 6, '郑凯', '110101199907071115', '13830000005', 1, '1999-07-07'),
                                                                                (11, 3, '周婷', '110101199808081116', '13830000006', 2, '1998-08-08');

-- =========================================================
-- 11. 初始化科室数据
-- =========================================================
INSERT INTO department (id, name, description, status) VALUES
                                                           (1, '内科', '主要负责常见内科疾病、慢性病、呼吸系统和消化系统相关疾病的诊疗。', 1),
                                                           (2, '外科', '主要负责普通外科疾病、创伤处理、术前术后咨询等诊疗服务。', 1),
                                                           (3, '儿科', '主要负责儿童常见病、多发病、生长发育咨询等医疗服务。', 1),
                                                           (4, '皮肤科', '主要负责皮肤疾病、过敏、湿疹、痤疮等相关诊疗服务。', 1),
                                                           (5, '口腔科', '主要负责牙齿、牙周、口腔黏膜等相关疾病诊疗服务。', 1);

-- =========================================================
-- 12. 初始化医生数据
-- 每个科室 2-3 名医生
-- =========================================================
INSERT INTO doctor (id, department_id, name, title, specialty, introduction, status) VALUES
                                                                                         (1, 1, '王建国', '主任医师', '高血压、糖尿病、慢性胃炎', '从事内科临床工作二十余年，擅长慢性病管理和常见内科疾病诊疗。', 1),
                                                                                         (2, 1, '刘敏', '副主任医师', '呼吸道感染、哮喘、慢性支气管炎', '擅长呼吸系统疾病诊疗，对慢性咳嗽和哮喘管理有丰富经验。', 1),
                                                                                         (3, 1, '陈志强', '主治医师', '消化不良、胃炎、肠道疾病', '主要研究消化系统常见疾病，注重患者长期健康管理。', 1),

                                                                                         (4, 2, '赵伟', '主任医师', '普外科、胆囊疾病、甲状腺疾病', '从事普外科临床工作多年，擅长常见外科疾病诊疗与手术评估。', 1),
                                                                                         (5, 2, '孙丽', '副主任医师', '创伤处理、术后恢复、乳腺疾病', '擅长外科门诊常见疾病处理及术后恢复指导。', 1),

                                                                                         (6, 3, '周芳', '主任医师', '儿童发热、咳嗽、消化不良', '长期从事儿科临床工作，擅长儿童常见病和多发病诊疗。', 1),
                                                                                         (7, 3, '吴磊', '主治医师', '儿童过敏、营养发育、呼吸道感染', '关注儿童生长发育和常见呼吸道疾病治疗。', 1),

                                                                                         (8, 4, '郑雪', '副主任医师', '痤疮、湿疹、皮肤过敏', '擅长皮肤科常见病诊疗，尤其关注痤疮和敏感肌问题。', 1),
                                                                                         (9, 4, '何强', '主治医师', '荨麻疹、皮炎、真菌感染', '擅长过敏性皮肤病及感染性皮肤病诊治。', 1),

                                                                                         (10, 5, '马琳', '主任医师', '牙周病、龋齿、口腔修复', '从事口腔临床工作多年，擅长牙周病和口腔修复治疗。', 1),
                                                                                         (11, 5, '高峰', '主治医师', '牙痛、拔牙、口腔检查', '擅长口腔门诊常见疾病诊疗和基础口腔保健指导。', 1);

-- =========================================================
-- 13. 初始化未来 7 天号源数据
-- 说明：
-- 从今天开始连续 7 天；业务层会按当前时间限制当天上午 11:30 后、当天下午 17:30 后不可预约
-- 每位医生每天上午、下午各一条号源
-- 上午默认 15 个号，下午默认 12 个号
-- =========================================================
INSERT INTO schedule (doctor_id, work_date, period, total_count, available_count, status)
SELECT
    d.id AS doctor_id,
    DATE_ADD(CURDATE(), INTERVAL days.day_num DAY) AS work_date,
    periods.period AS period,
    CASE
        WHEN periods.period = 'MORNING' THEN 15
        ELSE 12
        END AS total_count,
    CASE
        WHEN periods.period = 'MORNING' THEN 15
        ELSE 12
        END AS available_count,
    'AVAILABLE' AS status
FROM doctor d
         CROSS JOIN (
    SELECT 0 AS day_num
    UNION ALL SELECT 1
    UNION ALL SELECT 2
    UNION ALL SELECT 3
    UNION ALL SELECT 4
    UNION ALL SELECT 5
    UNION ALL SELECT 6
) days
         CROSS JOIN (
    SELECT 'MORNING' AS period
    UNION ALL SELECT 'AFTERNOON'
) periods
WHERE d.status = 1;

-- =========================================================
-- 14. 模拟部分特殊号源状态
-- 说明：用于前端展示“已约满”和“停诊”效果
-- 可根据需要删除
-- =========================================================

-- 将王建国医生后天上午设置为已约满
UPDATE schedule
SET available_count = 0,
    status = 'FULL'
WHERE doctor_id = 1
  AND work_date = DATE_ADD(CURDATE(), INTERVAL 2 DAY)
  AND period = 'MORNING';

-- 将赵伟医生第 3 天下午设置为停诊
UPDATE schedule
SET available_count = 0,
    status = 'STOPPED'
WHERE doctor_id = 4
  AND work_date = DATE_ADD(CURDATE(), INTERVAL 3 DAY)
  AND period = 'AFTERNOON';

-- =========================================================
-- 15. 初始化仿真预约记录
-- 说明：用于管理统计、我的预约、预约状态展示；每个测试账号不超过 3 个就诊人
-- =========================================================
INSERT INTO appointment (
    id, appointment_no, user_id, patient_id, department_id, doctor_id, schedule_id,
    visit_date, period, status, notice_sent, cancel_time
) VALUES
      (1, 'YYGH202605300001A1B2C3', 2, 1, 1, 1, (SELECT id FROM schedule WHERE doctor_id = 1 AND work_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY) AND period = 'MORNING'), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'MORNING', 'WAITING', 1, NULL),
      (2, 'YYGH202605300002B2C3D4', 2, 2, 2, 4, (SELECT id FROM schedule WHERE doctor_id = 4 AND work_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY) AND period = 'AFTERNOON'), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'AFTERNOON', 'WAITING', 1, NULL),
      (3, 'YYGH202605300003C3D4E5', 3, 3, 3, 6, (SELECT id FROM schedule WHERE doctor_id = 6 AND work_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY) AND period = 'MORNING'), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'MORNING', 'WAITING', 1, NULL),
      (4, 'YYGH202605300004D4E5F6', 2, 4, 4, 8, (SELECT id FROM schedule WHERE doctor_id = 8 AND work_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY) AND period = 'AFTERNOON'), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'AFTERNOON', 'CANCELLED', 1, NOW()),
      (5, 'YYGH202605300005E5F6A7', 3, 5, 5, 10, (SELECT id FROM schedule WHERE doctor_id = 10 AND work_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY) AND period = 'MORNING'), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'MORNING', 'WAITING', 1, NULL),
      (6, 'YYGH202605300006F6A7B8', 4, 6, 1, 2, (SELECT id FROM schedule WHERE doctor_id = 2 AND work_date = DATE_ADD(CURDATE(), INTERVAL 2 DAY) AND period = 'AFTERNOON'), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 'AFTERNOON', 'WAITING', 1, NULL),
      (7, 'YYGH202605300007A7B8C9', 5, 7, 2, 5, (SELECT id FROM schedule WHERE doctor_id = 5 AND work_date = DATE_ADD(CURDATE(), INTERVAL 2 DAY) AND period = 'MORNING'), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 'MORNING', 'WAITING', 1, NULL),
      (8, 'YYGH202605300008B8C9D0', 5, 8, 3, 7, (SELECT id FROM schedule WHERE doctor_id = 7 AND work_date = DATE_ADD(CURDATE(), INTERVAL 2 DAY) AND period = 'AFTERNOON'), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 'AFTERNOON', 'WAITING', 1, NULL),
      (9, 'YYGH202605300009C9D0E1', 6, 9, 4, 9, (SELECT id FROM schedule WHERE doctor_id = 9 AND work_date = DATE_ADD(CURDATE(), INTERVAL 2 DAY) AND period = 'MORNING'), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 'MORNING', 'WAITING', 1, NULL),
      (10, 'YYGH202605300010D0E1F2', 6, 10, 5, 11, (SELECT id FROM schedule WHERE doctor_id = 11 AND work_date = DATE_ADD(CURDATE(), INTERVAL 2 DAY) AND period = 'AFTERNOON'), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 'AFTERNOON', 'WAITING', 1, NULL),
      (11, 'YYGH202605300011E1F2A3', 3, 11, 1, 3, (SELECT id FROM schedule WHERE doctor_id = 3 AND work_date = DATE_ADD(CURDATE(), INTERVAL 3 DAY) AND period = 'MORNING'), DATE_ADD(CURDATE(), INTERVAL 3 DAY), 'MORNING', 'WAITING', 1, NULL),
      (12, 'YYGH202605300012F2A3B4', 2, 1, 2, 4, (SELECT id FROM schedule WHERE doctor_id = 4 AND work_date = DATE_ADD(CURDATE(), INTERVAL 3 DAY) AND period = 'MORNING'), DATE_ADD(CURDATE(), INTERVAL 3 DAY), 'MORNING', 'WAITING', 1, NULL),
      (13, 'YYGH202605300013A3B4C5', 2, 2, 3, 6, (SELECT id FROM schedule WHERE doctor_id = 6 AND work_date = DATE_ADD(CURDATE(), INTERVAL 3 DAY) AND period = 'AFTERNOON'), DATE_ADD(CURDATE(), INTERVAL 3 DAY), 'AFTERNOON', 'WAITING', 1, NULL),
      (14, 'YYGH202605300014B4C5D6', 3, 3, 4, 8, (SELECT id FROM schedule WHERE doctor_id = 8 AND work_date = DATE_ADD(CURDATE(), INTERVAL 3 DAY) AND period = 'MORNING'), DATE_ADD(CURDATE(), INTERVAL 3 DAY), 'MORNING', 'WAITING', 1, NULL),
      (15, 'YYGH202605300015C5D6E7', 2, 4, 5, 10, (SELECT id FROM schedule WHERE doctor_id = 10 AND work_date = DATE_ADD(CURDATE(), INTERVAL 3 DAY) AND period = 'AFTERNOON'), DATE_ADD(CURDATE(), INTERVAL 3 DAY), 'AFTERNOON', 'WAITING', 1, NULL),
      (16, 'YYGH202605300016D6E7F8', 3, 5, 1, 1, (SELECT id FROM schedule WHERE doctor_id = 1 AND work_date = DATE_ADD(CURDATE(), INTERVAL 4 DAY) AND period = 'AFTERNOON'), DATE_ADD(CURDATE(), INTERVAL 4 DAY), 'AFTERNOON', 'CANCELLED', 1, NOW()),
      (17, 'YYGH202605300017E7F8A9', 4, 6, 2, 5, (SELECT id FROM schedule WHERE doctor_id = 5 AND work_date = DATE_ADD(CURDATE(), INTERVAL 4 DAY) AND period = 'MORNING'), DATE_ADD(CURDATE(), INTERVAL 4 DAY), 'MORNING', 'WAITING', 1, NULL),
      (18, 'YYGH202605300018F8A9B0', 5, 7, 3, 7, (SELECT id FROM schedule WHERE doctor_id = 7 AND work_date = DATE_ADD(CURDATE(), INTERVAL 4 DAY) AND period = 'AFTERNOON'), DATE_ADD(CURDATE(), INTERVAL 4 DAY), 'AFTERNOON', 'WAITING', 1, NULL),
      (19, 'YYGH202605300019A9B0C1', 5, 8, 4, 9, (SELECT id FROM schedule WHERE doctor_id = 9 AND work_date = DATE_ADD(CURDATE(), INTERVAL 4 DAY) AND period = 'MORNING'), DATE_ADD(CURDATE(), INTERVAL 4 DAY), 'MORNING', 'WAITING', 1, NULL),
      (20, 'YYGH202605300020B0C1D2', 6, 9, 5, 11, (SELECT id FROM schedule WHERE doctor_id = 11 AND work_date = DATE_ADD(CURDATE(), INTERVAL 4 DAY) AND period = 'AFTERNOON'), DATE_ADD(CURDATE(), INTERVAL 4 DAY), 'AFTERNOON', 'WAITING', 1, NULL);

-- 根据未取消预约同步号源剩余数量，保留手工设置的约满和停诊状态
UPDATE schedule s
LEFT JOIN (
    SELECT schedule_id, COUNT(*) AS used_count
    FROM appointment
    WHERE status <> 'CANCELLED'
    GROUP BY schedule_id
) a ON a.schedule_id = s.id
SET s.available_count = CASE
        WHEN s.status IN ('FULL', 'STOPPED') AND COALESCE(a.used_count, 0) = 0 THEN 0
        ELSE GREATEST(s.total_count - COALESCE(a.used_count, 0), 0)
    END,
    s.status = CASE
        WHEN s.status = 'STOPPED' THEN 'STOPPED'
        WHEN s.status = 'FULL' AND COALESCE(a.used_count, 0) = 0 THEN 'FULL'
        WHEN GREATEST(s.total_count - COALESCE(a.used_count, 0), 0) = 0 THEN 'FULL'
        ELSE 'AVAILABLE'
    END;

-- =========================================================
-- 16. 查询验证
-- 执行完脚本后可以运行下面 SQL 检查数据
-- =========================================================

-- SELECT * FROM users;
-- SELECT * FROM patient;
-- SELECT * FROM department;
-- SELECT * FROM doctor;
-- SELECT * FROM schedule;
-- SELECT * FROM appointment;
