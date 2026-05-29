<template>
  <div class="stats-grid">
    <div>
      <h3>每日预约量</h3>
      <div class="stats-list">
        <div class="stats-row" v-for="(item, index) in dailyAppointments" :key="item.visitDate + '-' + index">
          <span>{{ item.visitDate }}</span>
          <strong>{{ item.total }}</strong>
        </div>
        <Empty v-if="!dailyAppointments.length" text="暂无每日预约数据" />
      </div>
    </div>
    <div>
      <h3>热门科室</h3>
      <div class="stats-list">
        <div class="stats-row" v-for="(item, index) in popularDepartments" :key="item.departmentName + '-' + index">
          <span>{{ item.departmentName }}</span>
          <strong>{{ item.total }}</strong>
        </div>
        <Empty v-if="!popularDepartments.length" text="暂无热门科室数据" />
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, type PropType } from 'vue'
import Empty from './Empty.vue'
import type { Statistics, StatisticsRow } from '../types'

export default defineComponent({
  name: 'StatsPanel',
  components: { Empty },
  props: {
    stats: { type: Object as PropType<Statistics>, required: true }
  },
  computed: {
    dailyAppointments(): StatisticsRow[] {
      return this.stats.dailyAppointments || []
    },
    popularDepartments(): StatisticsRow[] {
      return this.stats.popularDepartments || []
    }
  }
})
</script>
