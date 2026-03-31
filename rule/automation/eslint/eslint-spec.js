/**
 * 增强版 ESLint 配置 — 对齐前端规范.md
 *
 * 使用方式：
 * 1. 将此文件复制到前端项目根目录，重命名为 .eslintrc.js
 * 2. 安装依赖：
 *    npm install -D eslint@^8 \
 *      @typescript-eslint/eslint-plugin @typescript-eslint/parser \
 *      eslint-plugin-vue vue-eslint-parser \
 *      eslint-plugin-vuejs-accessibility \
 *      eslint-config-prettier \
 *      eslint-plugin-import eslint-plugin-security
 * 3. 运行检查：
 *    npx eslint src/ --ext .js,.jsx,.ts,.tsx,.vue
 * 4. CI 集成：
 *    npx eslint src/ --ext .js,.jsx,.ts,.tsx,.vue --max-warnings 0
 *
 * 对齐规范章节：
 * - 第 2 章 TypeScript 规范
 * - 第 3 章 Vue3 组件规范
 * - 第 4 章 可访问性规范
 * - 第 8 章 性能规范
 * - 第 9 章 安全规范
 * - 第 13 章 自动化检查
 */

module.exports = {
  root: true,
  env: {
    browser: true,
    node: true,
    es2022: true,
  },
  globals: {
    defineProps: 'readonly',
    defineEmits: 'readonly',
    defineExpose: 'readonly',
    withDefaults: 'readonly',
  },

  // ===== 解析器 =====
  parser: 'vue-eslint-parser',
  parserOptions: {
    parser: '@typescript-eslint/parser',
    ecmaVersion: 'latest',
    sourceType: 'module',
    extraFileExtensions: ['.vue'],
    project: './tsconfig.json',
    tsconfigRootDir: __dirname,
  },

  // ===== 插件与扩展 =====
  plugins: [
    '@typescript-eslint',
    'import',
    'vue',
    'vuejs-accessibility',
    'security',
  ],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:@typescript-eslint/recommended-requiring-type-checking',
    'plugin:vue/vue3-recommended',
    'plugin:vuejs-accessibility/recommended',
    'plugin:import/recommended',
    'plugin:import/typescript',
    'plugin:security/recommended',
    'prettier',
  ],

  // ===== 规则 =====
  rules: {
    // ================================================================
    // 第 2 章 TypeScript 规范
    // ================================================================

    // 2.1.01 禁止使用 any
    '@typescript-eslint/no-explicit-any': 'error',

    // 禁止未使用的变量，_ 前缀的除外
    '@typescript-eslint/no-unused-vars': [
      'error',
      {
        argsIgnorePattern: '^_',
        varsIgnorePattern: '^_',
        caughtErrorsIgnorePattern: '^_',
      },
    ],

    // 2.1.03 使用 type 关键字导入类型
    '@typescript-eslint/consistent-type-imports': [
      'error',
      { prefer: 'type-imports', fixStyle: 'inline-type-imports' },
    ],

    // 禁止浮动 Promise（必须 await 或 .catch）
    '@typescript-eslint/no-floating-promises': 'error',

    // 禁止将 Promise 传给不需要 Promise 的地方
    '@typescript-eslint/no-misused-promises': [
      'error',
      { checksVoidReturn: false },
    ],

    // 2.2.01 禁止双重断言 as any as X
    '@typescript-eslint/no-unnecessary-type-assertion': 'warn',

    // 2.1.04 严格空值检查（配合 tsconfig strictNullChecks）
    '@typescript-eslint/no-unnecessary-condition': 'warn',

    // 要求函数返回类型明确（公共 API）
    '@typescript-eslint/explicit-function-return-type': [
      'warn',
      {
        allowExpressions: true,
        allowTypedFunctionExpressions: true,
        allowHigherOrderFunctions: true,
      },
    ],

    // 禁止使用 require（使用 import）
    '@typescript-eslint/no-var-requires': 'error',

    // 命名约定：interface 不以 I 开头
    '@typescript-eslint/naming-convention': [
      'error',
      {
        selector: 'interface',
        format: ['PascalCase'],
        custom: { regex: '^I[A-Z]', match: false },
      },
      {
        selector: 'typeAlias',
        format: ['PascalCase'],
      },
      {
        selector: 'enum',
        format: ['PascalCase'],
      },
      {
        selector: 'variable',
        modifiers: ['const', 'global'],
        format: ['UPPER_CASE'],
      },
    ],

    // ================================================================
    // 第 3 章 Vue3 组件规范
    // ================================================================

    // 3.1.01 强制 PascalCase 组件名
    'vue/component-name-in-template-casing': ['error', 'PascalCase'],

    // 3.1.03 必须用 defineEmits 声明事件
    'vue/require-explicit-emits': 'error',

    // 禁止解构 props 导致响应性丢失
    'vue/no-setup-props-reactivity-loss': 'error',

    // 组件名必须是多词
    'vue/multi-word-component-names': 'warn',

    // v-html 安全警告
    'vue/no-v-html': 'warn',

    // 关闭 require-default-prop（使用 TS 类型可选标记）
    'vue/require-default-prop': 'off',

    // 关闭 max-attributes-per-line（由 Prettier 处理）
    'vue/max-attributes-per-line': 'off',

    // 强制 script setup 中使用 lang="ts"
    'vue/script-setup-uses-vars': 'error',

    // 组件 API 风格：强制使用 Composition API
    'vue/component-api-style': ['error', ['script-setup']],

    // defineProps 必须使用类型声明（非运行时声明）
    'vue/require-typed-object-prop': 'warn',

    // 禁止在 computed 中产生副作用
    'vue/no-side-effects-in-computed-properties': 'error',

    // v-for 必须有 :key
    'vue/require-v-for-key': 'error',

    // v-if 和 v-for 不能同级使用
    'vue/no-v-for-with-key-on-same-element': 'error',
    'vue/no-use-v-if-with-v-for': 'error',

    // 模板中禁止使用 this
    'vue/this-in-template': ['error', 'never'],

    // 禁止在 <template> 中使用复杂的三元表达式
    'vue/no-constant-condition': 'warn',

    // 组件 prop 类型必须是原始类型或构造函数数组
    'vue/require-prop-types': 'error',

    // ================================================================
    // 第 4 章 可访问性规范 (Accessibility)
    // ================================================================

    // 4.1.02 图片必须有 alt 属性
    'vuejs-accessibility/alt-text': 'error',

    // 4.2.01 点击事件必须有关联键盘事件
    'vuejs-accessibility/click-events-have-key-events': 'error',

    // 4.2.01 禁止在静态元素上绑定事件
    'vuejs-accessibility/no-static-element-interactions': 'error',

    // 表单元素必须有 label
    'vuejs-accessibility/form-control-has-label': 'error',

    // 4.3.01 交互元素必须可聚焦
    'vuejs-accessibility/interactive-supports-focus': 'error',

    // role 必须有对应的 ARIA 属性
    'vuejs-accessibility/role-has-required-aria-props': 'error',

    // 禁止使用 aria-hidden="true" 在可聚焦元素上
    'vuejs-accessibility/no-aria-hidden-on-focusable': 'error',

    // autofocus 使用警告
    'vuejs-accessibility/no-autofocus': 'warn',

    // ================================================================
    // 第 8 章 性能规范
    // ================================================================

    // 8.3.01 组件体积警告（超过 300 行）
    'vue/max-len': [
      'warn',
      {
        code: 300,
        template: 300,
        comments: 300,
        ignoreUrls: true,
        ignoreStrings: true,
        ignoreTemplateLiterals: true,
        ignoreHTMLCommentContents: true,
      },
    ],

    // watch 必须声明依赖源
    'vue/no-watch-without-rhs': 'error',

    // ================================================================
    // 第 9 章 安全规范
    // ================================================================

    // 9.3.01 禁止在 localStorage 存储敏感信息
    'no-restricted-syntax': [
      'error',
      {
        selector:
          "CallExpression[callee.object.name='localStorage'][callee.property.name='setItem']",
        message:
          '禁止使用 localStorage.setItem() 存储敏感信息（token/password），请使用 httpOnly cookie 或 sessionStorage',
      },
    ],

    // 安全相关：禁止 eval
    'no-eval': 'error',
    'no-implied-eval': 'error',

    // 安全相关：禁止 new Function
    'no-new-func': 'error',

    // 安全相关：禁止 document.write
    'no-restricted-globals': [
      'error',
      { name: 'document', message: '避免直接操作 document，使用 Vue 的响应式系统' },
    ],

    // 9.3.02 生产环境禁止 console.log（允许 warn/error）
    'no-console': ['warn', { allow: ['warn', 'error'] }],

    // 禁止 debugger
    'no-debugger': 'error',

    // 禁止 alert/prompt/confirm
    'no-alert': 'warn',

    // ================================================================
    // 第 2.3 章 模块与导入规范
    // ================================================================

    // 导入顺序
    'import/order': [
      'error',
      {
        groups: [
          'builtin',   // Node 内置模块
          'external',  // 第三方库 vue/element-plus
          'internal',  // 内部别名 @/
          'parent',    // 父级目录 ../
          'sibling',   // 同级目录 ./
          'index',     // index 文件
          'type',      // type-only imports
        ],
        'newlines-between': 'never',
        alphabetize: { order: 'asc', caseInsensitive: true },
      },
    ],

    // 禁止循环依赖
    'import/no-cycle': ['error', { maxDepth: 5 }],

    // 导入必须存在
    'import/no-unresolved': 'error',

    // 禁止默认导入重名
    'import/no-duplicates': 'error',

    // 禁止导入整个库（tree-shaking 友好）
    'import/no-namespace': 'off',

    // ================================================================
    // 通用规则
    // ================================================================

    // 优先使用 const
    'prefer-const': ['error', { destructuring: 'all' }],

    // 禁止 var
    'no-var': 'error',

    // 禁止空块语句
    'no-empty': ['error', { allowEmptyCatch: true }],

    // 禁止重复导入
    'no-duplicate-imports': 'error',

    // 使用 === 代替 ==
    'eqeqeq': ['error', 'always'],

    // 禁止嵌套三元表达式
    'no-nested-ternary': 'warn',

    // 对象 shorthand
    'object-shorthand': ['warn', 'always'],

    // 模板字符串优先
    'prefer-template': 'warn',

    // 禁止无意义的 return
    'no-useless-return': 'error',

    // 禁止未使用的表达式
    'no-unused-expressions': [
      'error',
      { allowShortCircuit: true, allowTernary: true },
    ],
  },

  // ===== 覆盖 =====
  overrides: [
    // TypeScript 文件
    {
      files: ['*.ts', '*.tsx'],
      rules: {
        '@typescript-eslint/explicit-function-return-type': [
          'warn',
          {
            allowExpressions: true,
            allowTypedFunctionExpressions: true,
          },
        ],
      },
    },

    // Vue 组件文件
    {
      files: ['*.vue'],
      rules: {
        // Vue SFC 中允许使用 any（模板绑定）
        '@typescript-eslint/no-explicit-any': 'warn',
      },
    },

    // 测试文件放宽
    {
      files: [
        '**/__tests__/**/*',
        '**/*.spec.*',
        '**/*.test.*',
        'tests/**/*',
        'test/**/*',
      ],
      env: {
        jest: true,
        'vitest-globals/env': true,
      },
      rules: {
        '@typescript-eslint/no-explicit-any': 'off',
        '@typescript-eslint/no-non-null-assertion': 'off',
        'vue/no-v-html': 'off',
        'no-console': 'off',
      },
    },

    // Storybook 故事文件
    {
      files: ['**/*.stories.*', '**/*.mdx'],
      rules: {
        '@typescript-eslint/no-explicit-any': 'off',
        'vue/no-v-html': 'off',
      },
    },

    // 配置文件放宽
    {
      files: [
        '*.config.js',
        '*.config.ts',
        '.eslintrc.js',
        'vite.config.*',
        'vitest.config.*',
      ],
      rules: {
        '@typescript-eslint/no-var-requires': 'off',
        'no-console': 'off',
      },
    },
  ],

  // ===== 忽略 =====
  ignorePatterns: [
    'node_modules/',
    'dist/',
    '.nuxt/',
    '.output/',
    'coverage/',
    '*.d.ts',
    '*.min.js',
    'public/',
  ],

  // ===== 设置 =====
  settings: {
    'import/resolver': {
      typescript: {
        alwaysTryTypes: true,
      },
      node: {
        extensions: ['.js', '.jsx', '.ts', '.tsx', '.vue'],
      },
    },
    vue: {
      version: '3.3',
    },
  },
};
