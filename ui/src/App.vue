<script setup>
import "@/assets/css/style.css";
import { ref, onMounted, onUnmounted, computed } from "vue";

const visible = ref(false);
const HUDvisible = ref(false);
const devmode = ref(false);
const fuel = ref(0);
const maxFuel = ref(0);
const condition = ref(0);
const maxCondition = ref(0);

const fuelLevel = computed(() => {
  return Math.round((fuel.value / maxFuel.value) * 100);
});

const conditionLevel = computed(() => {
  return Math.round((condition.value / maxCondition.value) * 100);
});

onMounted(() => {
  window.addEventListener("message", onMessage);
});

onUnmounted(() => {
  window.removeEventListener("message", onMessage);
});

const onMessage = (event) => {
  switch (event.data.type) {
    case "toggleHUD":
      HUDvisible.value = event.data.HUDvisible;
      condition.value = event.data.condition;
      maxCondition.value = event.data.maxCondition;
      fuel.value = event.data.fuel;
      maxFuel.value = event.data.maxFuel;
      break;
    case "update":
      if (event.data.fuel != null) {
        fuel.value = event.data.fuel;
      }

      if (event.data.condition != null) {
        condition.value = event.data.condition;
      }
      break;
    default:
      break;
  }
};
</script>

<template>
  <div class="wrapper" v-if="visible || devmode || HUDvisible">
    <!-- Possible UI for purchasing and selecting your train? -->
    <div v-if="visible">
      <div class="container">&nbsp;</div>
    </div>

    <!-- Only show if HUD is enabled -->
    <div v-if="HUDvisible" class="hud crock">
      <div>
        Fuel:
        <span
          :class="{
            bad: fuelLevel < 25,
            good: fuelLevel >= 25,
          }"
        >
          {{ fuelLevel }} %</span
        >
      </div>
      <div>
        Condition:
        <span
          :class="{
            bad: conditionLevel < 25,
            good: conditionLevel >= 25,
          }"
        >
          {{ conditionLevel }} %</span
        >
      </div>
    </div>
  </div>
</template>

<style scoped>
.bad {
  color: #ff0000;
  font-weight: bold;
}

.good {
  color: #0a6522;
  font-weight: bold;
}

.crock {
  font-family: "crock";
}
.hud {
  background-color: transparent;

  position: absolute;
  bottom: 5vh;
  left: 15vw;
  color: white;
  overflow: hidden;
}
</style>
