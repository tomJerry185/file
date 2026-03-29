# Shop 项目规范目录

> 本目录包含 Shop 电商项目的全部工程规范，按角色和场景组织导航。

---

## 📂 文件总览

| 文件 | 说明 | 版本 |
|------|------|------|
| [SKILL.md](SKILL.md) | AI 助手激励引擎——驱动 AI 主动执行、不放弃 | v3.0 |
| [后端规范.txt](后端规范.txt) | Java 后端工程标准（Spring Boot / 微服务 / DDD） | v2.0.1 |
| [前端规范.txt](前端规范.txt) | 前端工程标准（设计系统 / TypeScript / 组件规范 / 性能） | v2.0.1 |
| [中间件规范.txt](中间件规范.txt) | 中间件搭配使用标准（Nacos / Redis / RocketMQ / Seata / MySQL 等） | v2.0.1 |
| [工程治理规范.txt](工程治理规范.txt) | 工程治理标准（CI/CD / DORA / SLA·SLO / 安全 / 供应链） | v2.0.1 |
| [流程与规范手册.md](流程与规范手册.md) | 流程手册（需求分析 / 代码审查 / 事故管理 / RCA / 安全评审） | v2.0.1 |
| [模板.txt](模板.txt) | AI Prompt 模板（微服务启动调试助手） | v2.0 |

---

## 👤 按角色导航

### 🔧 后端开发者

| 我想… | 参见 |
|-------|------|
| 写 Controller / Service / Mapper | [后端规范.txt](后端规范.txt) 第2-6章 |
| 设计 RESTful API | [后端规范.txt](后端规范.txt) 第3章 |
| 处理异常和错误码 | [后端规范.txt](后端规范.txt) 第14章 |
| 用 Redis 缓存 / 分布式锁 | [中间件规范.txt](中间件规范.txt) 第3.1节 / 第4.5-4.6节 |
| 发 RocketMQ 消息 / 消费 | [中间件规范.txt](中间件规范.txt) 第3.2节 / 第4.7节 |
| 用 Seata 分布式事务 | [中间件规范.txt](中间件规范.txt) 第3.4节 / 第4.8节 |
| 配置 Spring Boot | [后端规范.txt](后端规范.txt) 第8章 |
| 写单元测试 / 集成测试 | [后端规范.txt](后端规范.txt) 第16章 |
| 调优 JVM / 数据库性能 | [后端规范.txt](后端规范.txt) 第18章 |

### 🎨 前端开发者

| 我想… | 参见 |
|-------|------|
| 查设计令牌（颜色/字体/间距） | [前端规范.txt](前端规范.txt) 第1章 |
| 写 Vue 组件 | [前端规范.txt](前端规范.txt) 第3章 |
| 处理状态管理 | [前端规范.txt](前端规范.txt) 第3.4节 |
| 适配可访问性 | [前端规范.txt](前端规范.txt) 第4章 |
| 响应式设计 | [前端规范.txt](前端规范.txt) 第5章 |
| 国际化 | [前端规范.txt](前端规范.txt) 第6章 |
| 优化性能（Core Web Vitals） | [前端规范.txt](前端规范.txt) 第8章 |
| 写测试 | [前端规范.txt](前端规范.txt) 第10章 |
| 配置 ESLint / Prettier | [前端规范.txt](前端规范.txt) 第13章 |

### 🛠 运维 / SRE

| 我想… | 参见 |
|-------|------|
| 配 CI/CD 流水线 | [工程治理规范.txt](工程治理规范.txt) 第4章 |
| 管理环境和配置 | [工程治理规范.txt](工程治理规范.txt) 第5章 |
| 设 SLA / SLO | [工程治理规范.txt](工程治理规范.txt) 第9章 |
| 处理事故 / On-call | [工程治理规范.txt](工程治理规范.txt) 第10章 |
| 配告警规则 | [工程治理规范.txt](工程治理规范.txt) 第8.4节 |
| 配发布策略（蓝绿/金丝雀） | [工程治理规范.txt](工程治理规范.txt) 第17章 |
| 管理依赖 / 供应链安全 | [工程治理规范.txt](工程治理规范.txt) 第12章 |
| 查 DORA 指标 | [工程治理规范.txt](工程治理规范.txt) 第15章 |

### 🏗 架构师

| 我想… | 参见 |
|-------|------|
| 架构评审 | [工程治理规范.txt](工程治理规范.txt) 第11章 |
| 管理技术债务 | [工程治理规范.txt](工程治理规范.txt) 第11.2节 |
| 写 ADR | [流程与规范手册.md](流程与规范手册.md) 第8.2节 |
| 安全评审（STRIDE） | [流程与规范手册.md](流程与规范手册.md) 第6章 |
| 隐私影响评估 | [流程与规范手册.md](流程与规范手册.md) 第7章 |
| 设计微服务拆分 | [后端规范.txt](后端规范.txt) 第9章 |

### 🤖 AI 助手使用者

| 我想… | 参见 |
|-------|------|
| 让 AI 主动不放弃 | [SKILL.md](SKILL.md) 三条铁律 / 压力升级 |
| 让 AI 按规范执行 | [SKILL.md](SKILL.md) 规范协同关系 |
| 调试微服务启动问题 | [模板.txt](模板.txt) 完整 Prompt 模板 |
| 查规范快速索引 | [SKILL.md](SKILL.md) 规范文件快速索引 |

---

## 🔍 按场景导航

### API 设计与开发

1. [后端规范.txt](后端规范.txt) 第3章 RESTful API 设计规范
2. [后端规范.txt](后端规范.txt) 第4章 Controller 层规范
3. [后端规范.txt](后端规范.txt) 第14章 异常与错误码规范
4. [中间件规范.txt](中间件规范.txt) 第4.2章 Spring Cloud Gateway

### 数据库与缓存

1. [后端规范.txt](后端规范.txt) 第11章 数据库规范
2. [后端规范.txt](后端规范.txt) 第12章 缓存与分布式锁
3. [中间件规范.txt](中间件规范.txt) 第3.1章 缓存与数据库
4. [中间件规范.txt](中间件规范.txt) 第4.5章 Redis / 第4.9章 MySQL

### 微服务通信

1. [后端规范.txt](后端规范.txt) 第9章 微服务架构规范
2. [中间件规范.txt](中间件规范.txt) 第3.2章 消息队列与数据库
3. [中间件规范.txt](中间件规范.txt) 第3.3章 网关与服务 / 第3.4章 分布式事务
4. [中间件规范.txt](中间件规范.txt) 第4.4章 OpenFeign / 第4.7章 RocketMQ / 第4.8章 Seata

### 安全与合规

1. [后端规范.txt](后端规范.txt) 第10章 安全规范
2. [前端规范.txt](前端规范.txt) 第9章 安全规范
3. [工程治理规范.txt](工程治理规范.txt) 第7章 安全与合规
4. [流程与规范手册.md](流程与规范手册.md) 第6章 安全评审 / 第7章 PIA
5. [中间件规范.txt](中间件规范.txt) 第2.5章 安全与合规

### 可观测性

1. [后端规范.txt](后端规范.txt) 第15章 可观测性规范
2. [中间件规范.txt](中间件规范.txt) 第2.3章 可观测性 / 第4.11章 日志与监控
3. [工程治理规范.txt](工程治理规范.txt) 第8章 可观测性
4. [工程治理规范.txt](工程治理规范.txt) 第9章 SLA/SLO 管理

### 测试

1. [后端规范.txt](后端规范.txt) 第16章 测试规范
2. [前端规范.txt](前端规范.txt) 第10章 测试规范
3. [工程治理规范.txt](工程治理规范.txt) 第6章 测试治理
4. [流程与规范手册.md](流程与规范手册.md) 第9章 DevOps 流程集成

### CI/CD 与发布

1. [工程治理规范.txt](工程治理规范.txt) 第4章 CI/CD 流水线
2. [工程治理规范.txt](工程治理规范.txt) 第17章 发布策略
3. [流程与规范手册.md](流程与规范手册.md) 第9章 DevOps 流程集成
4. [后端规范.txt](后端规范.txt) 第17章 CI/CD 与部署规范

### 事故与排障

1. [工程治理规范.txt](工程治理规范.txt) 第10章 事故管理
2. [流程与规范手册.md](流程与规范手册.md) 第4章 事件管理 / 第5章 RCA
3. [模板.txt](模板.txt) 第5章 错误分析协议 / 第6章 前后端联调

---

## 📋 项目技术栈版本

| 层级 | 技术 | 版本 |
|------|------|------|
| **运行时** | Java | 17 |
| **后端框架** | Spring Boot | 3.1.2 |
| **微服务** | Spring Cloud | 2022.0.3 |
| **微服务（阿里）** | Spring Cloud Alibaba | 2022.0.0.0-RC2 |
| **ORM** | MyBatis Plus | 3.5.3.1 |
| **认证** | Sa-Token | 1.37.0 |
| **分布式事务** | Seata | 1.7.1 |
| **限流熔断** | Sentinel | 1.8.6 |
| **消息队列** | RocketMQ Spring Boot Starter | 2.2.3 |
| **容错** | Resilience4j | 2.1.0 |
| **连接池** | Druid | 1.2.20 |
| **工具库** | Hutool | 5.8.21 |
| **数据库** | MySQL | 8.0.33 |
| **前端框架** | Vue | 3.3.4 |
| **前端路由** | Vue Router | 4.2.4 |
| **UI 组件库** | Element Plus | 2.3.8 |
| **构建工具** | Vite | 4.4.0 |
| **HTTP 客户端** | Axios | 1.4.0 |
| **日期处理** | dayjs | 1.11.7 |

---

## 🔧 自动化检查工具

自动化脚本与配置存放于 `rule/automation/` 目录，用于 CI/CD 集成或本地 pre-commit 检查。

### 目录结构

```
rule/automation/
├── checkstyle/
│   ├── checkstyle-enforced.xml       # 后端强制 Checkstyle 规则
│   └── checkstyle-suppressions.xml   # 老代码抑制配置
├── scripts/
│   ├── check-backend-rules.sh        # 后端规范合规检查
│   ├── check-frontend-rules.sh       # 前端规范合规检查
│   └── check-middleware-rules.sh     # 中间件规范合规检查
├── archunit/
│   └── ArchUnitRules.java            # 架构分层测试模板
├── eslint/
│   └── eslint-spec.js                # 增强版 ESLint 配置
├── prometheus-alerts.yml             # 对齐实际指标的告警规则
└── grafana-dashboard.json            # 监控看板模板
```

### 使用方式

**后端规范检查**（对齐《后端规范.txt》）：
```bash
# 本地运行
bash rule/automation/scripts/check-backend-rules.sh .

# CI 集成（Makefile / GitHub Actions）
bash rule/automation/scripts/check-backend-rules.sh $PROJECT_ROOT
```

**前端规范检查**（对齐《前端规范.txt》）：
```bash
bash rule/automation/scripts/check-frontend-rules.sh frontend/
```

**中间件规范检查**（对齐《中间件规范.txt》）：
```bash
bash rule/automation/scripts/check-middleware-rules.sh .
```

**Checkstyle（Java 代码风格）**：
```bash
mvn checkstyle:check -Dcheckstyle.config.location=rule/automation/checkstyle/checkstyle-enforced.xml
```

**ArchUnit 架构测试**：
```bash
# 将 ArchUnitRules.java 复制到 src/test/java 对应包下
cp rule/automation/archunit/ArchUnitRules.java <service>/src/test/java/com/example/
mvn test -Dtest=ArchUnitRules
```

**ESLint 增强配置**：
```bash
# 将 eslint-spec.js 合并到前端 .eslintrc.js 中
cp rule/automation/eslint/eslint-spec.js frontend/eslint-spec.js
```

**Prometheus 告警规则**：
```bash
# 加载到 Prometheus
promtool check rules rule/automation/prometheus-alerts.yml
```

### 脚本检查项速查

| 脚本 | 检查项 | 对齐规范文件 |
|------|--------|-------------|
| check-backend-rules.sh | @Autowired 字段注入、SELECT *、printStackTrace、Controller 直接调 Mapper、硬编码密码/IP、缺少 @Transactional | 后端规范.txt |
| check-frontend-rules.sh | console.log 残留、硬编码文案、v-html 未净化、TypeScript any、缺少 aria-label | 前端规范.txt |
| check-middleware-rules.sh | 硬编码连接信息、缺少超时配置、未配置死信队列、未配置重试上限 | 中间件规范.txt |
| checkstyle-enforced.xml | 命名规范、import 顺序、代码复杂度 | 后端规范.txt |
| ArchUnitRules.java | 分层架构、Controller 不调 Mapper、Service 接口规范 | 后端规范.txt |
| eslint-spec.js | TS 类型安全、Vue3 Composition API、可访问性 | 前端规范.txt |
| prometheus-alerts.yml | 服务可用性、错误率、延迟、连接池、缓存命中率 | 工程治理规范.txt |

### 输出格式

所有 Shell 脚本输出带行号的合规报告，格式如下：
```
[FAIL] 后端规范 5.1.01 - 发现 @Autowired 字段注入
  → order-center/src/main/java/.../OrderService.java:25
[WARN] 后端规范 6.1.01 - 发现 SELECT * 查询
  → biz-center/src/main/resources/mapper/ProductMapper.xml:45
```

---

## ⚠️ 已知偏差

| 问题 | 状态 | 说明 |
|------|------|------|
| 前端规范以 React 为主，项目实际使用 Vue3 | 🟢 已修复 | 已将所有 React 示例改为 Vue3 Composition API + Element Plus |
| 联系方式为占位符 | 🟢 已修复 | 已删除所有占位符邮箱，保留通用占位符 `[PLACEHOLDER_COMPANY]` |
| 工程治理规范与流程手册部分内容重叠 | 🟢 已修复 | 已增加交叉引用，明确文档职责划分 |

---

## 📋 版本兼容性矩阵

### 后端技术栈

| 技术 | 当前版本 | 最低支持 | 升级路径 | 升级风险 |
|------|----------|----------|----------|----------|
| Java | 17 LTS | 11 LTS | 11 → 14 → 17 | 中 |
| Spring Boot | 3.1.2 | 2.7.x | 2.7 → 3.0 → 3.1 | 低 |
| Spring Cloud | 2022.0.3 | 2020.0.x | 2020 → 2021 → 2022 | 中 |
| MyBatis Plus | 3.5.3.1 | 3.3.x | 3.3 → 3.4 → 3.5 | 低 |
| Sa-Token | 1.37.0 | 1.30.x | 1.30 → 1.34 → 1.37 | 低 |
| Seata | 1.7.1 | 1.5.x | 1.5 → 1.6 → 1.7 | 中 |
| Sentinel | 1.8.6 | 1.7.x | 1.7 → 1.8 → 1.9 | 低 |
| Hutool | 5.8.21 | 5.4.x | 5.4 → 5.6 → 5.8 | 低 |
| Druid | 1.2.20 | 1.1.x | 1.1 → 1.2 → 1.2 | 低 |

### 前端技术栈

| 技术 | 当前版本 | 最低支持 | 升级路径 | 升级风险 |
|------|----------|----------|----------|----------|
| Vue | 3.3.4 | 2.7.x | 2.7 → 3.0 → 3.3 | 中 |
| Vue Router | 4.2.4 | 3.x | 3 → 4 → 4.2 | 中 |
| Element Plus | 2.3.8 | 2.3.x | 2.3 → 2.4 → 2.3 | 低 |
| Vite | 4.4.0 | 3.x | 3 → 4 → 4.4 | 低 |
| Axios | 1.4.0 | 1.x | 1 → 2 | 低 |
| dayjs | 1.11.7 | 1.10.x | 1.10 → 1.11 → 1.12 | 低 |

### 中间件技术栈

| 技术 | 当前版本 | 最低支持 | 升级路径 | 升级风险 |
|------|----------|----------|----------|----------|
| MySQL | 8.0.33 | 5.7.x | 5.7 → 8.0 | 高 |
| Redis | 7.0.14 | 6.x | 6 → 7 | 高 |
| RocketMQ | 5.1.4 | 4.x | 4 → 5 | 中 |
| Nacos | 2.2.3 | 2.0.x | 2.0 → 2.1 → 2.2 | 低 |
| Seata | 1.7.1 | 1.5.x | 1.5 → 1.6 → 1.7 | 中 |
| Sentinel | 1.8.6 | 1.7.x | 1.7 → 1.8 → 1.9 | 低 |

### 升级策略

| 风险等级 | 升级前检查清单 | 升级后验证 | 回滚方案 |
|----------|----------------|----------|----------|
| 高 | 功能兼容性测试、性能基准测试 | 功能回归测试、性能对比 | 版本标签回滚 |
| 中 | API 变更影响分析、依赖冲突检查 | 集成测试、冒烟测试 | 依赖版本锁定 |
| 低 | 文档阅读、破坏性变更扫描 | 单元测试通过 | Git revert |

### 兼容性检查清单

- [ ] Java 版本检查（`java -version`）
- [ ] Node.js 版本检查（`node -v`）
- [ ] Maven/Gradle 依赖检查（`mvn dependency:tree`）
- [ ] 依赖漏洞扫描（`npm audit` / `mvn dependency-check`）
- [ ] API 变更影响分析（查看 Deprecated 警告）
- [ ] 数据库迁移脚本验证
- [ ] 缓存键名变更验证
- [ ] 微服务通信协议版本确认

### 参考资源

| 名称 | 链接 | 用途 |
|------|------|------|
| Java 版本兼容性 | https://openjdk.org/projects/jdk | JDK 升级路径 |
| Spring Boot 版本兼容性 | https://github.com/spring-projects/spring-boot/wiki | Spring Boot 升级指南 |
| Vue 版本兼容性 | https://v2.vuejs.org/guide/migration/ | Vue 2.x 迁移指南 |
| Node.js 版本发布计划 | https://github.com/nodejs/Release | Node.js 发布计划 |
| MySQL 版本说明 | https://dev.mysql.com/doc/relnotes/mysql/ | MySQL 版本说明 |
| Redis 版本说明 | https://redis.io/documentation | Redis 版本说明 |