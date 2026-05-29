<template>
  <section class="page-view">
    <div class="section-head">
      <div>
        <h1>挂号预约</h1>
        <p>实名就诊，按科室、医生、号源和就诊人完成预约。</p>
      </div>
      <div class="head-actions">
        <button class="notice-button" type="button">挂号须知</button>
      </div>
    </div>

    <form class="booking-search" @submit.prevent="$emit('search', $event)">
      <div>
        <strong>快速查找</strong>
        <span>支持按科室名称或医生姓名搜索</span>
      </div>
      <input :value="keyword" @input="updateKeyword" placeholder="例如：内科、儿科、王建国" />
      <button>搜索</button>
    </form>

    <div class="clinic-brief">
      <div>
        <span>实名预约</span>
        <strong>就诊人信息需与证件一致</strong>
      </div>
      <div>
        <span>取消规则</span>
        <strong>创建后 30 分钟内可取消</strong>
      </div>
      <div>
        <span>就诊提醒</span>
        <strong>请提前到院取号候诊</strong>
      </div>
    </div>

    <Panel v-if="searchDoctors.length > 0" title="医生搜索结果">
      <div class="search-result-grid">
        <button class="row" type="button" v-for="doctor in searchDoctors" :key="doctor.id" @click="$emit('openDoctor', doctor)">
          <strong>{{ doctor.name }} · {{ doctor.title }}</strong>
          <small>{{ doctor.departmentName }}</small>
          <span>{{ doctor.specialty }}</span>
          <p v-if="doctor.introduction" class="doctor-intro">{{ doctor.introduction }}</p>
        </button>
      </div>
    </Panel>

    <div class="steps">
      <div
        v-for="(step, index) in ['选择科室', '选择医生', '选择号源', '确认预约']"
        :key="step"
        :class="['step', { active: currentStep === index + 1, done: currentStep > index + 1 }]"
      >
        <b>{{ index + 1 }}</b>
        <span>{{ step }}</span>
      </div>
    </div>

    <div :class="['booking-grid', 'step-' + currentStep]">
      <Panel title="科室">
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
            <i>查看医生</i>
          </button>
          <Empty v-if="!departments.length" text="暂无匹配科室，请清空搜索条件后重试" />
        </div>
      </Panel>

      <Panel v-if="selectedDepartment" title="医生">
        <div class="list">
          <button
            v-for="doctor in doctors"
            :key="doctor.id"
            type="button"
            :class="['row', { selected: selectedDoctor?.id === doctor.id }]"
            @click="$emit('loadSchedules', doctor)"
          >
            <strong>{{ doctor.name }} · {{ doctor.title }}</strong>
            <small>{{ doctor.departmentName }}</small>
            <span>{{ doctor.specialty }}</span>
            <p v-if="doctor.introduction" class="doctor-intro">{{ doctor.introduction }}</p>
          </button>
          <Empty v-if="!doctors.length" text="当前科室暂无医生" />
        </div>
      </Panel>

      <Panel v-if="selectedDoctor" title="号源">
        <div class="slot-grid">
          <button
            v-for="schedule in schedules"
            :key="schedule.id"
            type="button"
            :disabled="schedule.status !== 'AVAILABLE' || schedule.availableCount <= 0"
            :class="['slot', schedule.status.toLowerCase(), { selected: selectedSchedule?.id === schedule.id }]"
            @click="$emit('update:selectedSchedule', schedule)"
          >
            <span>{{ schedule.workDate }}</span>
            <strong>{{ periodText[schedule.period] }}</strong>
            <em>{{ statusText[schedule.status] }}</em>
            <small>剩余 {{ schedule.availableCount }} / {{ schedule.totalCount }}</small>
          </button>
          <Empty v-if="!schedules.length" text="当前医生暂无号源" />
        </div>
      </Panel>

      <Panel v-if="selectedSchedule" title="确认预约">
        <div class="summary">
          <label>
            就诊人
            <select :value="selectedPatientId" @change="updateSelectedPatient">
              <option value="">请选择</option>
              <option v-for="patient in patients" :key="patient.id" :value="patient.id">{{ patient.name }}</option>
            </select>
          </label>
          <div class="summary-line"><span>科室</span><strong>{{ selectedDepartment?.name || '-' }}</strong></div>
          <div class="summary-line"><span>医生</span><strong>{{ selectedDoctor?.name || '-' }}</strong></div>
          <div class="summary-line"><span>日期</span><strong>{{ selectedSchedule?.workDate || '-' }}</strong></div>
          <div class="summary-line"><span>时段</span><strong>{{ selectedSchedule ? periodText[selectedSchedule.period] : '-' }}</strong></div>
          <div class="notice">
            提交后将生成预约号，成功记录会进入“我的预约”。30 分钟内可取消，超过后不可取消。
          </div>
          <button class="primary" type="button" :disabled="!canSubmit" @click="$emit('createAppointment')">提交预约</button>
        </div>
      </Panel>
    </div>
  </section>
</template>

<script lang="ts">
import { defineComponent, type PropType } from 'vue'
import Panel from '../components/Panel.vue'
import Empty from '../components/Empty.vue'
import { periodText, statusText } from '../constants'
import type { Department, Doctor, Patient, Schedule } from '../types'

export default defineComponent({
  name: 'BookingView',
  components: { Panel, Empty },
  props: {
    departments: { type: Array as PropType<Department[]>, required: true },
    doctors: { type: Array as PropType<Doctor[]>, required: true },
    schedules: { type: Array as PropType<Schedule[]>, required: true },
    searchDoctors: { type: Array as PropType<Doctor[]>, required: true },
    patients: { type: Array as PropType<Patient[]>, required: true },
    selectedDepartment: { type: Object as PropType<Department | null>, default: null },
    selectedDoctor: { type: Object as PropType<Doctor | null>, default: null },
    selectedSchedule: { type: Object as PropType<Schedule | null>, default: null },
    selectedPatientId: { type: [Number, String], default: '' },
    canSubmit: { type: Boolean, required: true },
    keyword: { type: String, required: true }
  },
  emits: [
    'update:selectedPatientId',
    'update:selectedSchedule',
    'update:keyword',
    'loadDoctors',
    'loadSchedules',
    'createAppointment',
    'search',
    'openDoctor'
  ],
  data() {
    return { periodText, statusText }
  },
  computed: {
    currentStep(): number {
      if (this.selectedSchedule) return 4
      if (this.selectedDoctor) return 3
      if (this.selectedDepartment) return 2
      return 1
    }
  },
  methods: {
    updateKeyword(event: Event) {
      this.$emit('update:keyword', (event.target as HTMLInputElement).value)
    },
    updateSelectedPatient(event: Event) {
      const value = (event.target as HTMLSelectElement).value
      this.$emit('update:selectedPatientId', Number(value) || '')
    }
  }
})
</script>
