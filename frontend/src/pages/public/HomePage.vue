<template>
  <div class="min-h-screen bg-gray-50">
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-4xl font-bold text-center text-gray-900 mb-8">
        ClubBridge 跨校選社系統
      </h1>
      <div class="text-center">
        <p class="text-lg text-gray-600 mb-8">
          現代化的多租戶跨校選社管理平台
        </p>
        <div class="space-x-4">
          <router-link
            to="/apply"
            class="btn-primary"
          >
            申請新學校
          </router-link>
          <button class="btn-secondary">
            學生登入
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// 首頁邏輯
</script>