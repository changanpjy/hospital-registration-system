<template>
  <section class="page-view">
    <div class="section-head">
      <div>
        <h1>我的预约</h1>
        <p>查看预约号、就诊时间和状态，预约成功记录统一在这里查看。</p>
      </div>
    </div>
    <Panel title="预约记录">
      <div class="appointment-table">
        <div class="appointment-row" v-for="appointment in appointments" :key="appointment.id">
          <div>
            <strong>{{ appointment.departmentName }} · {{ appointment.doctorName }}</strong>
            <span>{{ appointment.patientName }} / {{ appointment.visitDate }} {{ periodText[appointment.period] }}</span>
            <small v-if="appointment.noticeSent === 1" class="notice-status">预约确认通知已发送</small>
          </div>
          <code>{{ appointment.appointmentNo }}</code>
          <span :class="['chip', appointment.status.toLowerCase()]">{{ appointmentText[appointment.status] }}</span>
          <button class="ghost" type="button" :disabled="!canCancelAppointment(appointment)" @click="$emit('cancelAppointment', appointment.id)">取消</button>
        </div>
        <Empty v-if="!appointments.length" text="暂无预约记录" />
      </div>
    </Panel>
  </section>
</template>

<script lang="ts">
import { defineComponent, type PropType } from 'vue'
import Panel from '../components/Panel.vue'
import Empty from '../components/Empty.vue'
import { appointmentText, periodText } from '../constants'
import type { Appointment } from '../types'

export default defineComponent({
  name: 'AppointmentsView',
  components: { Panel, Empty },
  props: {
    appointments: { type: Array as PropType<Appointment[]>, required: true }
  },
  emits: ['cancelAppointment'],
  data() {
    return { periodText, appointmentText }
  },
  methods: {
    canCancelAppointment(appointment: Appointment): boolean {
      if (appointment.status !== 'WAITING' || !appointment.createTime) return false
      return Date.now() - new Date(appointment.createTime).getTime() <= 30 * 60 * 1000
    }
  }
})
</script>
