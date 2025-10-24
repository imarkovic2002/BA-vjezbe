<template>
  <div>
    <h1>
      {{ title }}
    </h1>
    <h1>Broj: {{ broj }}</h1>
    <button @click="povecaj">+</button>
    <button @click="smanji">-</button>
  </div>
</template>

<script setup>
import { ref } from 'vue'

// const props = defineProps({ title: String })

const broj = ref(0)

const emit = defineEmits(['enlarge'])
emit('enlarge', broj.value)

function povecaj() {
  broj.value++
  console.log('Inkrementirano')
}

function smanji() {
  broj.value--
  console.log('Dekrementirano')
}
</script>
