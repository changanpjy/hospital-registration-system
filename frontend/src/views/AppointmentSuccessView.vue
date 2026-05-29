<template>
  <section class="page-view">
    <div class="success-hero">
      <div class="success-mark">✓</div>
      <div>
        <span>预约提交成功</span>
        <h1>{{ appointment?.appointmentNo || '预约已生成' }}</h1>
        <p>请按预约日期和时段提前到院取号候诊，预约确认通知已模拟发送。</p>
      </div>
    </div>

    <Panel title="预约详情">
      <div v-if="appointment" class="success-detail">
        <div class="success-line">
          <span>预约号</span>
          <code>{{ appointment.appointmentNo }}</code>
        </div>
        <div class="success-line">
          <span>就诊人</span>
          <strong>{{ appointment.patientName }}</strong>
        </div>
        <div class="success-line">
          <span>科室</span>
          <strong>{{ appointment.departmentName }}</strong>
        </div>
        <div class="success-line">
          <span>医生</span>
          <strong>{{ appointment.doctorName }}</strong>
        </div>
        <div class="success-line">
          <span>就诊日期</span>
          <strong>{{ appointment.visitDate }}</strong>
        </div>
        <div class="success-line">
          <span>就诊时段</span>
          <strong>{{ periodText[appointment.period] }}</strong>
        </div>
        <div class="success-line">
          <span>预约状态</span>
          <span :class="['chip', appointment.status.toLowerCase()]">{{ appointmentText[appointment.status] }}</span>
        </div>
        <div class="success-line">
          <span>确认通知</span>
          <strong>{{ appointment.noticeSent === 1 ? '已发送通知' : '未发送通知' }}</strong>
        </div>
      </div>
      <Empty v-else text="暂无预约详情，请到我的预约中查看记录" />
    </Panel>

    <div class="clinic-brief">
      <div>
        <span>取号提醒</span>
        <strong>请提前到院取号候诊</strong>
      </div>
      <div>
        <span>证件要求</span>
        <strong>就诊人与证件信息需一致</strong>
      </div>
      <div>
        <span>取消规则</span>
        <strong>创建后 30 分钟内可取消</strong>
      </div>
    </div>

    <div class="success-actions">
      <button type="button" @click="$emit('viewAppointments')">查看我的预约</button>
      <button class="ghost" type="button" @click="$emit('bookAgain')">继续挂号</button>
    </div>
  </section>
</template>

<script lang="ts">
import { defineComponent, type PropType } from 'vue'
import Panel from '../components/Panel.vue'
import Empty from '../components/Empty.vue'
import { appointmentText, periodText } from '../constants'
import type { Appointment } from '../types'

export default defineComponent({
  name: 'AppointmentSuccessView',
  components: { Panel, Empty },
  props: {
    appointment: { type: Object as PropType<Appointment | null>, default: null }
  },
  emits: ['viewAppointments', 'bookAgain'],
  data() {
    return { appointmentText, periodText }
  }
})
</script>
