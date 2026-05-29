<template>
  <section class="page-view">
    <div class="section-head">
      <div>
        <h1>管理统计</h1>
        <p>管理员可查看门诊预约概况，并维护医生未来日期号源。</p>
      </div>
    </div>
    <Panel v-if="user?.role !== 'ADMIN'" title="权限提示">
      <Empty text="管理员登录后可查看和维护排班" />
    </Panel>
    <Panel title="统计面板">
      <StatsPanel v-if="stats" :stats="stats" />
      <Empty v-else :text="user?.role === 'ADMIN' ? '暂无统计数据' : '管理员登录后可查看'" />
    </Panel>
    <div v-if="user?.role === 'ADMIN'" class="admin-schedules">
      <div class="admin-pick-grid">
        <Panel title="选择科室">
          <div class="list">
            <button
              v-for="department in departments"
              :key="department.id"
              type="button"
              :class="['row', { selected: selectedDepartment?.id === department.id }]"
              @click="$emit('loadDoctors', department)"
            >
              <strong>{{ department.name }}</strong>
              <span>{{ department.description }}</span>
            </button>
          </div>
        </Panel>
        <Panel title="选择医生">
          <div v-if="selectedDepartment" class="list">
            <button
              v-for="doctor in doctors"
              :key="doctor.id"
              type="button"
              :class="['row', { selected: selectedDoctor?.id === doctor.id }]"
              @click="$emit('loadSchedules', doctor)"
            >
              <strong>{{ doctor.name }}</strong>
              <small>{{ doctor.title }}</small>
            </button>
            <Empty v-if="!doctors.length" text="当前科室暂无医生" />
          </div>
          <Empty v-else text="请选择左侧科室查看医生" />
        </Panel>
      </div>
      <div ref="scheduleSection" class="admin-schedule-section">
        <Panel title="排班号源">
          <div class="admin-schedule-list">
            <div class="admin-schedule-row" v-for="schedule in schedules" :key="schedule.id">
              <strong>{{ schedule.workDate }} {{ periodText[schedule.period] }}</strong>
              <input type="number" min="0" :value="editValue(schedule, 'totalCount')" @input="changeScheduleEditFromEvent(schedule, 'totalCount', $event)" />
              <input type="number" min="0" :value="editValue(schedule, 'availableCount')" @input="changeScheduleEditFromEvent(schedule, 'availableCount', $event)" />
              <select :value="editValue(schedule, 'status')" @change="changeScheduleEditFromEvent(schedule, 'status', $event)">
                <option value="AVAILABLE">可预约</option>
                <option value="FULL">已约满</option>
                <option value="STOPPED">停诊</option>
              </select>
              <button type="button" @click="$emit('updateSchedule', schedule)">保存</button>
            </div>
            <Empty v-if="!schedules.length" text="请选择医生查看排班" />
          </div>
        </Panel>
      </div>
    </div>
  </section>
</template>

<script lang="ts">
import { defineComponent, type PropType } from 'vue'
import Panel from '../components/Panel.vue'
import Empty from '../components/Empty.vue'
import StatsPanel from '../components/StatsPanel.vue'
import { periodText } from '../constants'
import type { Department, Doctor, Schedule, ScheduleEdit, ScheduleStatus, Statistics, User } from '../types'

export default defineComponent({
  name: 'AdminView',
  components: { Panel, Empty, StatsPanel },
  props: {
    user: { type: Object as PropType<User | null>, default: null },
    stats: { type: Object as PropType<Statistics | null>, default: null },
    departments: { type: Array as PropType<Department[]>, required: true },
    doctors: { type: Array as PropType<Doctor[]>, required: true },
    schedules: { type: Array as PropType<Schedule[]>, required: true },
    selectedDepartment: { type: Object as PropType<Department | null>, default: null },
    selectedDoctor: { type: Object as PropType<Doctor | null>, default: null },
    scheduleEdits: { type: Object as PropType<Record<number, ScheduleEdit>>, required: true }
  },
  emits: ['loadDoctors', 'loadSchedules', 'changeScheduleEdit', 'updateSchedule'],
  data() {
    return { periodText }
  },
  watch: {
    selectedDoctor(newDoctor: Doctor | null, oldDoctor: Doctor | null) {
      if (!newDoctor || newDoctor?.id === oldDoctor?.id) return
      this.$nextTick(() => {
        ;(this.$refs.scheduleSection as HTMLElement | undefined)?.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        })
      })
    }
  },
  methods: {
    getScheduleEdit(schedule: Schedule): ScheduleEdit {
      return this.scheduleEdits[schedule.id] || {
        totalCount: schedule.totalCount,
        availableCount: schedule.availableCount,
        status: schedule.status
      }
    },
    editValue(schedule: Schedule, field: keyof ScheduleEdit): number | ScheduleStatus {
      return this.getScheduleEdit(schedule)[field]
    },
    changeScheduleEdit(schedule: Schedule, field: keyof ScheduleEdit, value: string) {
      this.$emit('changeScheduleEdit', {
        schedule,
        field,
        value: field === 'status' ? value : Number(value)
      })
    },
    changeScheduleEditFromEvent(schedule: Schedule, field: keyof ScheduleEdit, event: Event) {
      const target = event.target as HTMLInputElement | HTMLSelectElement
      this.changeScheduleEdit(schedule, field, target.value)
    }
  }
})
</script>
