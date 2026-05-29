<template>
  <section class="panel">
    <h2>{{ title }}</h2>
    <slot />
  </section>
</template>

<script lang="ts">
import { defineComponent } from 'vue'

export default defineComponent({
  name: 'Panel',
  props: {
    title: { type: String, required: true }
  }
})
</script>
