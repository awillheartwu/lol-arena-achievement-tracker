<template>
  <div class="p-4">
    <!-- 成功提示弹出框 -->
    <div v-if="showToast"
      class="fixed top-4 left-1/2 transform -translate-x-1/2 bg-green-500 text-white px-4 py-2 rounded shadow-lg z-50">
      英雄数据已更新到最新版本！
    </div>

    <!-- 当前英雄数据版本号显示 -->
    <p class="text-sm text-center text-gray-400 mt-1">当前版本：{{ version }}</p>

    <!-- 操作按钮和搜索栏 -->
    <div class="flex flex-wrap justify-center gap-2 mt-4">
      <!-- 搜索框 -->
      <input v-model="search" placeholder="搜索英雄名称或称号" class="px-4 py-2 rounded bg-gray-800 text-white w-[400px]" />

      <!-- 全选 / 全不选切换按钮 -->
      <button @click="toggleSelectAll" class="bg-green-500 hover:bg-green-600 text-white px-2 rounded text-sm">
        {{ isAllSelected ? '全不选' : '全选' }}
      </button>

      <!-- 手动更新按钮 -->
      <button @click="updateChampions" class="bg-blue-500 hover:bg-blue-600 text-white px-2 rounded text-sm">
        更新英雄数据
      </button>

      <!-- 导出勾选按钮 -->
      <button @click="exportChecked" class="bg-yellow-500 hover:bg-yellow-600 text-white px-2 py-1 rounded text-sm">
        导出勾选
      </button>

      <!-- 导入勾选按钮（用 label + input） -->
      <label
        class="bg-purple-500 hover:bg-purple-600 text-white px-2 py-1 rounded text-sm cursor-pointer inline-flex items-center">
        导入勾选
        <input type="file" @change="importChecked" accept=".json" class="hidden" />
      </label>

    </div>

    <!-- 过滤按钮与勾选计数器 -->
    <div class="flex justify-center gap-2 mt-2 text-sm">
      <span class="text-white">筛选：</span>
      <button @click="filter = 'all'" :class="filterBtnClass('all')">全部</button>
      <button @click="filter = 'checked'" :class="filterBtnClass('checked')">已勾选</button>
      <button @click="filter = 'unchecked'" :class="filterBtnClass('unchecked')">未勾选</button>
      <span class="ml-4 text-white">当前已完成：{{ checkedCount }} / {{ champions.length }}</span>
    </div>

    <!-- 英雄头像展示区 -->
    <TransitionGroup name="fade" tag="div" class="grid grid-cols-6 gap-4 justify-center mt-6">
      <div v-for="c in filteredSortedChampions" :key="c.id" @click="toggle(c.id)"
        class="relative cursor-pointer rounded overflow-hidden transform hover:scale-105 duration-200"
        :class="{ 'border-4 border-green-400': checked[c.id] }">
        <!-- 英雄头像图片 -->
        <img class="w-full h-auto object-cover" :class="{ 'brightness-50': checked[c.id] }"
          :src="ICON_BASE + c.image.full" :alt="c.name" />

        <!-- 勾选后的绿色小角标 -->
        <span v-if="checked[c.id]"
          class="absolute top-1 right-1 bg-green-500 w-4 h-4 rounded-full flex items-center justify-center text-white text-xs">
          ✓
        </span>

        <!-- 英雄名字和称号 -->
        <div class="text-center text-sm text-white mt-1">
          {{ c.name }} · {{ c.title }}
        </div>
      </div>
    </TransitionGroup>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from "vue";

// Riot API：获取所有版本
const VERSION_API = "https://ddragon.leagueoflegends.com/api/versions.json";
const LANG = "zh_CN"; // 使用中文数据

// 响应式变量定义
const version = ref(""); // 当前游戏数据版本
const champions = ref([]); // 所有英雄数据列表
const checked = ref({}); // 勾选状态对象 { id: true/false }
const search = ref(""); // 搜索关键词
const filter = ref("all"); // 当前过滤状态
const showToast = ref(false); // 是否显示更新成功提示

// 头像URL基准路径，根据版本生成
const ICON_BASE = computed(() => `https://ddragon.leagueoflegends.com/cdn/${version.value}/img/champion/`);

// 获取最新版本号（版本列表第一个即最新）
const fetchLatestVersion = async () => {
  const res = await fetch(VERSION_API);
  const versions = await res.json();
  return versions[0];
};

// 根据版本获取英雄数据（中文）
const fetchChampionData = async (ver) => {
  const url = `https://ddragon.leagueoflegends.com/cdn/${ver}/data/${LANG}/champion.json`;
  const res = await fetch(url);
  const data = await res.json();
  return Object.values(data.data).sort((a, b) => a.key - b.key);
};

// 页面挂载时初始化：获取版本和数据，读取本地存储
onMounted(async () => {
  version.value = await fetchLatestVersion();
  const local = localStorage.getItem("arena-checked");
  if (local) checked.value = JSON.parse(local);
  champions.value = await fetchChampionData(version.value);
});

// 手动更新英雄数据，并合并旧的勾选状态
const updateChampions = async () => {
  const latest = await fetchLatestVersion();
  version.value = latest;
  const newList = await fetchChampionData(latest);
  newList.forEach((c) => {
    if (!(c.id in checked.value)) checked.value[c.id] = false;
  });
  champions.value = newList;
  showSuccessToast();
};

// 显示绿色提示框 2 秒
const showSuccessToast = () => {
  showToast.value = true;
  setTimeout(() => {
    showToast.value = false;
  }, 2000);
};

// 点击头像切换勾选状态
const toggle = (id) => {
  checked.value[id] = !checked.value[id];
};

// 是否全选
const isAllSelected = computed(() =>
  Object.values(checked.value).every(Boolean)
);

// 切换全选或全不选
const toggleSelectAll = () => {
  const target = !isAllSelected.value;
  Object.keys(checked.value).forEach((k) => {
    checked.value[k] = target;
  });
};

// 监听勾选状态变化写入本地存储
watch(
  checked,
  () => {
    localStorage.setItem("arena-checked", JSON.stringify(checked.value));
  },
  { deep: true }
);

// 筛选 + 搜索 + 拼音排序后的英雄列表
const filteredSortedChampions = computed(() => {
  const filtered = champions.value.filter((c) => {
    if (filter.value === "checked") return checked.value[c.id];
    if (filter.value === "unchecked") return !checked.value[c.id];
    return true;
  });
  return filtered
    .filter((c) => c.name.includes(search.value) || c.title.includes(search.value))
    .sort((a, b) => a.name.localeCompare(b.name, "zh-Hans-CN-u-co-pinyin"));
});

// 计算当前已勾选数量
const checkedCount = computed(() =>
  Object.values(checked.value).filter(Boolean).length
);

// 过滤按钮的样式函数（根据选中状态变色）
const filterBtnClass = (val) =>
  `px-2 rounded text-sm ${filter.value === val ? "bg-blue-500 text-white" : "bg-gray-700 text-gray-200"
  } hover:bg-blue-600`;

// 导出当前勾选状态为 JSON 文件
const exportChecked = () => {
  const dataStr = JSON.stringify(checked.value, null, 2);
  const blob = new Blob([dataStr], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "arena-checked.json";
  a.click();
  URL.revokeObjectURL(url);
};

// 从 JSON 文件导入勾选状态（合并）
const importChecked = (event) => {
  const file = event.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = (e) => {
    try {
      const imported = JSON.parse(e.target.result);
      Object.entries(imported).forEach(([key, val]) => {
        checked.value[key] = val;
      });
      showSuccessToast();
    } catch (err) {
      alert("导入失败，请检查文件格式");
    }
  };
  reader.readAsText(file);
};
</script>

<style scoped>
/* 淡入淡出动画 */
.fade-enter-active,
.fade-leave-active {
  transition: all 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: scale(0.95);
}
</style>
