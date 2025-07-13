<template>
  <div class="min-h-screen bg-gray-50">
    <!-- 學校層級的簡單容器，不含側邊欄 -->
    <router-view />
  </div>
</template>
<script setup lang="ts">
// SchoolLayout：學校層級的基礎容器
// 不包含導航欄，讓子路由決定具體的佈局（如 SchoolAdminLayout）
</script>
