<template>
  <section class="page-view">
    <div class="section-head">
      <div>
        <h1>用户管理</h1>
        <p>管理员可查看用户账号，并启用或禁用普通用户。</p>
      </div>
      <button type="button" @click="$emit('refreshUsers')">刷新</button>
    </div>
    <Panel v-if="user?.role !== 'ADMIN'" title="权限提示">
      <Empty text="仅管理员可查看用户管理" />
    </Panel>
    <Panel v-else title="用户列表">
      <div class="user-table">
        <div class="user-row user-row-head">
          <strong>账号</strong>
          <span>联系方式</span>
          <span>角色</span>
          <span>状态</span>
          <span>操作</span>
        </div>
        <div class="user-row" v-for="managedUser in users" :key="managedUser.id">
          <strong>{{ managedUser.username }}</strong>
          <span>{{ contactText(managedUser) }}</span>
          <span>{{ roleText(managedUser.role) }}</span>
          <span :class="['chip', managedUser.status === 0 ? 'cancelled' : 'waiting']">
            {{ managedUser.status === 0 ? '已禁用' : '正常' }}
          </span>
          <button
            class="ghost"
            type="button"
            :disabled="managedUser.id === user?.id"
            @click="$emit('toggleUserStatus', managedUser)"
          >
            {{ managedUser.status === 0 ? '启用' : '禁用' }}
          </button>
        </div>
        <Empty v-if="!users.length" text="暂无用户数据" />
      </div>
    </Panel>
  </section>
</template>

<script lang="ts">
import { defineComponent, type PropType } from 'vue'
import Panel from '../components/Panel.vue'
import Empty from '../components/Empty.vue'
import type { Role, User } from '../types'

export default defineComponent({
  name: 'UserManagementView',
  components: { Panel, Empty },
  props: {
    user: { type: Object as PropType<User | null>, default: null },
    users: { type: Array as PropType<User[]>, required: true }
  },
  emits: ['refreshUsers', 'toggleUserStatus'],
  methods: {
    contactText(user: User): string {
      return [user.phone, user.email].filter(Boolean).join(' / ') || '未填写'
    },
    roleText(role: Role): string {
      return role === 'ADMIN' ? '管理员' : '普通用户'
    }
  }
})
</script>
