<template>
  <div class="auth-box">
    <div class="auth-tabs">
      <button type="button" :class="{ active: authMode === 'login' }" @click="$emit('update:authMode', 'login')">登录</button>
      <button type="button" :class="{ active: authMode === 'register' }" @click="$emit('update:authMode', 'register')">注册</button>
    </div>

    <form v-if="authMode === 'login'" class="login" @submit.prevent="$emit('login', $event)">
      <input :value="account" @input="updateAccount" placeholder="用户名 / 手机号 / 邮箱" />
      <input :value="password" @input="updatePassword" type="password" placeholder="密码" />
      <button>登录</button>
    </form>

    <form v-else class="register" @submit.prevent="$emit('register', $event)">
      <div class="register-method">
        <button type="button" :class="{ active: registerType === 'phone' }" @click="$emit('update:registerType', 'phone')">手机号注册</button>
        <button type="button" :class="{ active: registerType === 'email' }" @click="$emit('update:registerType', 'email')">邮箱注册</button>
      </div>
      <input :value="registerForm.username" @input="updateRegisterFormFromEvent('username', $event)" placeholder="用户名" required />
      <input
        v-if="registerType === 'phone'"
        :value="registerForm.phone"
        @input="updateRegisterFormFromEvent('phone', $event)"
        maxlength="11"
        inputmode="numeric"
        pattern="^1\d{10}$"
        placeholder="手机号"
        title="请输入以1开头的11位手机号"
        required
      />
      <input
        v-else
        :value="registerForm.email"
        @input="updateRegisterFormFromEvent('email', $event)"
        type="email"
        placeholder="邮箱"
        required
      />
      <input :value="registerForm.password" @input="updateRegisterFormFromEvent('password', $event)" type="password" placeholder="密码" required />
      <button>注册并登录</button>
    </form>
  </div>
</template>

<script lang="ts">
import { defineComponent, type PropType } from 'vue'
import type { RegisterForm, RegisterType } from '../types'

export default defineComponent({
  name: 'AuthBox',
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
    'register'
  ],
  methods: {
    inputValue(event: Event): string {
      return (event.target as HTMLInputElement).value
    },
    updateAccount(event: Event) {
      this.$emit('update:account', this.inputValue(event))
    },
    updatePassword(event: Event) {
      this.$emit('update:password', this.inputValue(event))
    },
    updateRegisterForm(field: keyof RegisterForm, value: string) {
      this.$emit('update:registerForm', { ...this.registerForm, [field]: value })
    },
    updateRegisterFormFromEvent(field: keyof RegisterForm, event: Event) {
      const value = field === 'phone'
        ? this.inputValue(event).replace(/\D/g, '').slice(0, 11)
        : this.inputValue(event)
      this.updateRegisterForm(field, value)
    }
  }
})
</script>
