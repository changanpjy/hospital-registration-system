<template>
  <section class="page-view auth-page">
    <div class="auth-hero">
      <div class="auth-copy">
        <span>在线挂号服务</span>
        <h1>{{ authMode === 'login' ? '账号登录' : '患者注册' }}</h1>
        <p>登录后可管理就诊人、提交预约并查看预约记录。注册后即可维护本人或家属信息。</p>
        <div class="auth-benefits">
          <div><b>1</b><strong>管理就诊人</strong><small>一个账号维护多个就诊人</small></div>
          <div><b>2</b><strong>预约挂号</strong><small>查看医生未来 7 天号源</small></div>
          <div><b>3</b><strong>记录追踪</strong><small>查看预约号和预约状态</small></div>
        </div>
      </div>
      <div class="auth-card">
        <AuthBox
          :auth-mode="authMode"
          :account="account"
          :password="password"
          :register-type="registerType"
          :register-form="registerForm"
          @update:auth-mode="$emit('update:authMode', $event)"
          @update:account="$emit('update:account', $event)"
          @update:password="$emit('update:password', $event)"
          @update:register-type="$emit('update:registerType', $event)"
          @update:register-form="$emit('update:registerForm', $event)"
          @login="$emit('login', $event)"
          @register="$emit('register', $event)"
        />
        <button class="back-link" type="button" @click="$emit('back')">返回挂号预约</button>
      </div>
    </div>
  </section>
</template>

<script lang="ts">
import { defineComponent, type PropType } from 'vue'
import AuthBox from '../components/AuthBox.vue'
import type { RegisterForm, RegisterType } from '../types'

export default defineComponent({
  name: 'AuthView',
  components: { AuthBox },
  props: {
    authMode: { type: String, required: true },
    account: { type: String, required: true },
    password: { type: String, required: true },
    registerType: { type: String as PropType<RegisterType>, required: true },
    registerForm: { type: Object as PropType<RegisterForm>, required: true }
  },
  emits: [
    'update:authMode',
    'update:account',
    'update:password',
    'update:registerType',
    'update:registerForm',
    'login',
    'register',
    'back'
  ]
})
</script>
