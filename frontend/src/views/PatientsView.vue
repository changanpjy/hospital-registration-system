<template>
  <section class="page-view">
    <div class="section-head">
      <div>
        <h1>就诊人管理</h1>
        <p>维护本人及家属实名就诊信息，预约时可直接选择。</p>
      </div>
    </div>
    <div class="two-column">
      <Panel title="新增就诊人">
        <form class="patient-form" @submit.prevent="$emit('addPatient', $event)">
          <input :value="newPatient.name" @input="updatePatientFromEvent('name', $event)" placeholder="姓名" maxlength="50" required />
          <input
            :value="newPatient.idCard"
            @input="updatePatientFromEvent('idCard', $event, true)"
            placeholder="身份证号"
            maxlength="18"
            pattern="[0-9]{17}[0-9Xx]"
            title="请输入18位身份证号"
            required
          />
          <input
            :value="newPatient.phone"
            @input="updatePatientFromEvent('phone', $event, true)"
            placeholder="手机号"
            maxlength="11"
            inputmode="tel"
            pattern="1[0-9]{10}"
            title="请输入以1开头的11位手机号"
            required
          />
          <input :value="newPatient.birthDate" @input="updatePatientFromEvent('birthDate', $event)" type="date" />
          <button :disabled="!user">添加就诊人</button>
        </form>
      </Panel>
      <Panel title="已有就诊人">
        <div class="table">
          <div class="table-row" v-for="patient in patients" :key="patient.id">
            <strong>{{ patient.name }}</strong>
            <span>{{ patient.idCard }}</span>
            <span>{{ patient.phone }}</span>
          </div>
          <Empty v-if="!patients.length" text="暂无就诊人" />
        </div>
      </Panel>
    </div>
  </section>
</template>

<script lang="ts">
import { defineComponent, type PropType } from 'vue'
import Panel from '../components/Panel.vue'
import Empty from '../components/Empty.vue'
import type { Patient, PatientForm, User } from '../types'

export default defineComponent({
  name: 'PatientsView',
  components: { Panel, Empty },
  props: {
    user: { type: Object as PropType<User | null>, default: null },
    patients: { type: Array as PropType<Patient[]>, required: true },
    newPatient: { type: Object as PropType<PatientForm>, required: true }
  },
  emits: ['update:newPatient', 'addPatient'],
  methods: {
    updatePatient(field: keyof PatientForm, value: string) {
      this.$emit('update:newPatient', { ...this.newPatient, [field]: value })
    },
    updatePatientFromEvent(field: keyof PatientForm, event: Event, trim = false) {
      const value = (event.target as HTMLInputElement).value
      this.updatePatient(field, trim ? value.trim() : value)
    }
  }
})
</script>
