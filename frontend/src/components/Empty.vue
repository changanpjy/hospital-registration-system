<template>
  <div class="empty">{{ text }}</div>
</template>

<script lang="ts">
import { defineComponent } from 'vue'

export default defineComponent({
  name: 'Empty',
  props: {
    text: { type: String, required: true }
  }
})
</script>
