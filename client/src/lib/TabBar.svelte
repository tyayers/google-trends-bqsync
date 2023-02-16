<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  const dispatch = createEventDispatcher();
    
  export let tabs: string[] = []
  export let selectedTab: string = ""
  
  function selectTab(name) {
    selectedTab = name;
    dispatch('tabSelect', {
      name: name
    });
  }
</script>

<div class="tabbar">
  <div class="tabbar-label">
    Regions
  </div>
  {#each tabs as tab}
    <div class="tabbar-tab" class:selected="{selectedTab === tab}" on:click={() => { selectTab(tab)}}>
      {tab}
    </div>
  {/each}
</div>

<style>
  .tabbar {
    width: 100%;
    border-bottom: 1px solid #f2f2f2;
    font-family: sans-serif;
  }
  
  .tabbar-label {
    font-weight: 450;
    font-size: 16px;
    color: #999;
    height: 90%;
    padding-left: 10px;
    padding-right: 10px;
    margin-top: 1px;
    margin-bottom: 5px;
    padding-top: 5px;    
    display: inline-block;  
  }
  
  .tabbar-tab {
    font-weight: 450;
    font-size: 14px;
    cursor: pointer;
    color: #999;
    height: 90%;
    padding-left: 10px;
    padding-right: 10px;
    margin-top: 1px;
    margin-bottom: 1px;
    padding-top: 5px;
    display: inline-block;
  }
  
  .selected {
    font-weight: 550;
  }
</style>