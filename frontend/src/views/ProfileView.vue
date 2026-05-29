<template>
  <section class="page-view">
    <div class="section-head">
      <div>
        <h1>个人中心</h1>
      </div>
    </div>
    <Panel title="账号信息">
      <form class="profile-form" @submit.prevent="$emit('updateProfile', $event)">
        <label>
          <span>用户名</span>
          <input :value="profileForm.username" :disabled="!editing" @input="updateProfileFromEvent('username', $event)" maxlength="50" required />
        </label>
        <label>
          <span>手机号</span>
          <input
            :value="profileForm.phone"
            :disabled="!editing"
            @input="updateProfileFromEvent('phone', $event, true)"
            maxlength="11"
            inputmode="tel"
            pattern="1[0-9]{10}"
            title="请输入以1开头的11位手机号"
          />
        </label>
        <label>
          <span>邮箱</span>
          <input :value="profileForm.email" :disabled="!editing" @input="updateProfileFromEvent('email', $event)" type="email" />
        </label>
        <button v-if="!editing" type="button" :disabled="!user" @click="$emit('editProfile')">编辑信息</button>
        <button v-else type="submit" :disabled="!user">保存信息</button>
      </form>
    </Panel>
  </section>
</template>

<script lang="ts">
import { defineComponent, type PropType } from 'vue'
import Panel from '../components/Panel.vue'
import type { ProfileForm, User } from '../types'

export default defineComponent({
  name: 'ProfileView',
  components: { Panel },
  props: {
    user: { type: Object as PropType<User | null>, default: null },
    profileForm: { type: Object as PropType<ProfileForm>, required: true },
    editing: { type: Boolean, required: true }
  },
  emits: ['update:profileForm', 'editProfile', 'updateProfile'],
  methods: {
    updateProfile(field: keyof ProfileForm, value: string) {
      this.$emit('update:profileForm', { ...this.profileForm, [field]: value })
    },
    updateProfileFromEvent(field: keyof ProfileForm, event: Event, digitsOnly = false) {
      const value = (event.target as HTMLInputElement).value
      this.updateProfile(field, digitsOnly ? value.replace(/\D/g, '').slice(0, 11) : value)
    }
  }
})
</script>
