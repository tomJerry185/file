package com.example.archunit;

import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.importer.ClassFileImporter;
import com.tngtech.archunit.lang.ArchRule;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.*;
import static com.tngtech.archunit.library.dependencies.SlicesRuleDefinition.slices;

/**
 * ArchUnit 架构规则测试模板
 *
 * 使用方式：
 * 1. 将此文件复制到各服务的 src/test/java 对应包下
 * 2. 添加依赖：
 *    <dependency>
 *        <groupId>com.tngtech.archunit</groupId>
 *        <artifactId>archunit-junit5</artifactId>
 *        <version>1.2.1</version>
 *        <scope>test</scope>
 *    </dependency>
 * 3. 根据实际包结构调整 PACKAGE 常量
 * 4. 运行 mvn test -Dtest=ArchUnitRules
 *
 * 对齐规范：
 * - 后端规范.txt 1.2.02 分层架构
 * - 后端规范.txt 2.1.01 Controller职责
 * - 后端规范.txt 2.2.01 Service接口规范
 */
class ArchUnitRules {

    // TODO: 修改为实际的服务包路径
    private static final String BASE_PACKAGE = "org.example";
    private static final String CONTROLLER_PACKAGE = "..controller..";
    private static final String SERVICE_PACKAGE = "..service..";
    private static final String MAPPER_PACKAGE = "..mapper..";
    private static final String DTO_PACKAGE = "..dto..";
    private static final String ENTITY_PACKAGE = "..entity..";
    private static final String CONFIG_PACKAGE = "..config..";

    private final JavaClasses classes = new ClassFileImporter()
            .importPackages(BASE_PACKAGE);

    // =========================================================================
    // 规则 1: Controller 不能直接调用 Mapper/Repository
    // 后端规范 1.2.02 / 2.1.01
    // =========================================================================

    @Test
    @DisplayName("Controller不能直接依赖Mapper层")
    void controller_should_not_depend_on_mapper() {
        ArchRule rule = noClasses()
                .that().resideInAPackage(CONTROLLER_PACKAGE)
                .should().dependOnClassesThat()
                .resideInAPackage(MAPPER_PACKAGE)
                .because("Controller不能直接调用Mapper，必须通过Service层（后端规范 1.2.02）");

        rule.check(classes);
    }

    // =========================================================================
    // 规则 2: Service 必须有接口 + 实现类
    // 后端规范 2.2.01
    // =========================================================================

    @Test
    @DisplayName("Service实现类必须有对应接口")
    void service_impl_should_have_interface() {
        ArchRule rule = classes()
                .that().resideInAPackage(SERVICE_PACKAGE)
                .and().haveSimpleNameEndingWith("Impl")
                .should().implement(havingNameEndingWith("Service"))
                .because("Service实现类必须实现对应接口（后端规范 2.2.01）");

        rule.check(classes);
    }

    // =========================================================================
    // 规则 3: Controller 命名规范
    // 后端规范 2.1.02
    // =========================================================================

    @Test
    @DisplayName("Controller类必须以Controller结尾")
    void controller_naming_convention() {
        ArchRule rule = classes()
                .that().resideInAPackage(CONTROLLER_PACKAGE)
                .and().areNotInnerClasses()
                .should().haveSimpleNameEndingWith("Controller")
                .because("Controller类必须以Controller结尾（后端规范 2.1.02）");

        rule.check(classes);
    }

    // =========================================================================
    // 规则 4: Mapper 命名规范
    // 后端规范 2.3.01
    // =========================================================================

    @Test
    @DisplayName("Mapper接口必须以Mapper结尾")
    void mapper_naming_convention() {
        ArchRule rule = classes()
                .that().resideInAPackage(MAPPER_PACKAGE)
                .and().areInterfaces()
                .should().haveSimpleNameEndingWith("Mapper")
                .because("Mapper接口必须以Mapper结尾（后端规范 2.3.01）");

        rule.check(classes);
    }

    // =========================================================================
    // 规则 5: 包命名规范检查
    // 后端规范 1.2.01
    // =========================================================================

    @Test
    @DisplayName("包命名应为小写字母")
    void package_naming_convention() {
        ArchRule rule = classes()
                .should().resideInAPackageMatching("[a-z_.]+")
                .because("包名必须为小写字母（后端规范 1.2.01）");

        rule.check(classes);
    }

    // =========================================================================
    // 规则 6: 禁止循环依赖
    // =========================================================================

    @Test
    @DisplayName("包之间不应有循环依赖")
    void no_package_cycles() {
        ArchRule rule = slices()
                .matching(BASE_PACKAGE + ".(*)..")
                .should().beFreeOfCycles();

        rule.check(classes);
    }

    // =========================================================================
    // 规则 7: Config 类不应该依赖 Service 层
    // =========================================================================

    @Test
    @DisplayName("Config类不应依赖Service层")
    void config_should_not_depend_on_service() {
        ArchRule rule = noClasses()
                .that().resideInAPackage(CONFIG_PACKAGE)
                .should().dependOnClassesThat()
                .resideInAPackage(SERVICE_PACKAGE)
                .because("配置类不应依赖业务Service，应通过参数注入或事件机制解耦");

        rule.check(classes);
    }

    // =========================================================================
    // 规则 8: Entity 不应该依赖 Service/Controller 层
    // 后端规范 1.2.02 层级依赖规则
    // =========================================================================

    @Test
    @DisplayName("Entity不应依赖Service或Controller")
    void entity_should_not_depend_on_upper_layers() {
        ArchRule rule = noClasses()
                .that().resideInAPackage(ENTITY_PACKAGE)
                .should().dependOnClassesThat()
                .resideInAnyPackage(SERVICE_PACKAGE, CONTROLLER_PACKAGE)
                .because("Entity是底层数据模型，不应依赖上层（后端规范 1.2.02）");

        rule.check(classes);
    }
}
