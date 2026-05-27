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

                         UNIQUE KEY uk_patient_id_card (id_card),
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

                        KEY idx_doctor_department_id (department_id),
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

                          UNIQUE KEY uk_schedule_doctor_date_period (doctor_id, work_date, period),
                          KEY idx_schedule_doctor_id (doctor_id),
                          KEY idx_schedule_work_date (work_date),
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

                             UNIQUE KEY uk_appointment_no (appointment_no),
                             UNIQUE KEY uk_patient_department_date (patient_id, department_id, visit_date),
                             KEY idx_appointment_user_id (user_id),
                             KEY idx_appointment_patient_id (patient_id),
                             KEY idx_appointment_schedule_id (schedule_id),
                             KEY idx_appointment_status (status),
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
-- =========================================================
INSERT INTO users (id, username, phone, email, password, role, status) VALUES
                                                                           (1, 'admin', '13800000000', 'admin@hospital.com', '123456', 'ADMIN', 1),
                                                                           (2, 'zhangsan', '13811111111', 'zhangsan@example.com', '123456', 'PATIENT', 1),
                                                                           (3, 'lisi', '13822222222', 'lisi@example.com', '123456', 'PATIENT', 1);

-- =========================================================
-- 10. 初始化就诊人数据
-- =========================================================
INSERT INTO patient (id, user_id, name, id_card, phone, gender, birth_date) VALUES
                                                                                (1, 2, '张三', '110101199801011234', '13811111111', 1, '1998-01-01'),
                                                                                (2, 2, '张小明', '110101201005051234', '13811111111', 1, '2010-05-05'),
                                                                                (3, 3, '李四', '110101199902021234', '13822222222', 1, '1999-02-02');

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
-- 从今天开始连续 7 天；上午时段查询时会隐藏今天上午，仅保留今天下午可预约
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
-- 15. 查询验证
-- 执行完脚本后可以运行下面 SQL 检查数据
-- =========================================================

-- SELECT * FROM users;
-- SELECT * FROM patient;
-- SELECT * FROM department;
-- SELECT * FROM doctor;
-- SELECT * FROM schedule;
-- SELECT * FROM appointment;
